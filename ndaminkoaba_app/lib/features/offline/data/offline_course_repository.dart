import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../lessons/data/lesson_repository.dart';
import '../../lessons/domain/lesson.dart';
import '../../lessons/domain/models/lesson_image.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/domain/quiz.dart';
import '../../vocabulary/data/vocabulary_repository.dart';
import '../../vocabulary/domain/vocabulary_word.dart';
import '../domain/course_download_manifest.dart';

class _PendingAsset {
  const _PendingAsset(this.remoteUrl, this.localPath);
  final String remoteUrl;
  final String localPath;
}

/// Metadata fetched for one lesson before its binary assets are downloaded
/// — kept separate from [OfflineLesson] because a target path here isn't
/// promoted to a real `localPath` until [OfflineCourseRepository] confirms
/// the download actually succeeded (see `downloadCourse`).
class _LessonBuilder {
  _LessonBuilder({
    required this.lesson,
    required this.images,
    required this.vocabulary,
    required this.quiz,
    this.lessonAudioTarget,
    required this.imageTargets,
    required this.vocabTargets,
  });

  final Lesson lesson;
  final List<LessonImage> images;
  final List<VocabularyWord> vocabulary;
  final Quiz? quiz;
  final String? lessonAudioTarget;
  final Map<String, String> imageTargets;
  final Map<String, String> vocabTargets;
}

class _ModuleBuilder {
  _ModuleBuilder({required this.moduleJson, required this.lessons});
  final Map<String, dynamic> moduleJson;
  final List<_LessonBuilder> lessons;
}

/// Downloads a whole course (content, vocabulary, quiz-preview text, and
/// binary assets) to disk for offline use, and manages the on-disk manifest
/// + `shared_preferences`-backed download index. No local database — course
/// counts here are tens of lessons, not thousands (see the offline-mode
/// plan's rationale), so a flat JSON manifest per course is enough.
class OfflineCourseRepository {
  final _lessonRepository = LessonRepository();
  final _vocabularyRepository = VocabularyRepository();
  final _quizRepository = QuizRepository();

  static const _indexKey = 'offline_downloaded_course_ids';

  Future<Directory> _courseDir(String courseId) async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/offline/$courseId');
  }

  Future<File> _manifestFile(String courseId) async {
    final dir = await _courseDir(courseId);
    return File('${dir.path}/manifest.json');
  }

  String _assetPath(Directory courseDir, String filename) =>
      '${courseDir.path}/assets/$filename';

  String _extensionFor(String url) {
    final uri = Uri.tryParse(url);
    final last = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last
        : '';
    final dot = last.lastIndexOf('.');
    return dot == -1 ? '' : last.substring(dot);
  }

  /// Downloads one binary asset to [file]. Failures are swallowed (return
  /// `false`) rather than aborting the whole course download — a learner
  /// should still get a mostly-offline course rather than nothing if one
  /// image or audio clip fails mid-download.
  Future<bool> _downloadAsset(String remoteUrl, File file) async {
    try {
      final response = await Dio().get<List<int>>(
        AppConfig.resolveUrl(remoteUrl),
        options: Options(responseType: ResponseType.bytes),
      );
      await file.parent.create(recursive: true);
      await file.writeAsBytes(response.data!);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> getDownloadedCourseIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_indexKey) ?? [];
  }

  Future<bool> isDownloaded(String courseId) async {
    return (await getDownloadedCourseIds()).contains(courseId);
  }

  Future<void> _addToIndex(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_indexKey) ?? [];
    if (!ids.contains(courseId)) {
      await prefs.setStringList(_indexKey, [...ids, courseId]);
    }
  }

  Future<void> _removeFromIndex(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_indexKey) ?? [];
    ids.remove(courseId);
    await prefs.setStringList(_indexKey, ids);
  }

  Future<CourseDownloadManifest?> loadManifest(String courseId) async {
    final file = await _manifestFile(courseId);
    if (!await file.exists()) return null;
    try {
      final raw = await file.readAsString();
      return CourseDownloadManifest.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> removeDownload(String courseId) async {
    final dir = await _courseDir(courseId);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await _removeFromIndex(courseId);
  }

  /// Fetches the course's full content (via the same `GET /courses/:id`
  /// `course_detail_screen.dart` already calls, which nests full raw
  /// `Lesson` rows — not the thin `CourseDetailLesson` nav-list shape) plus
  /// each lesson's images/vocabulary/quiz-preview, downloads every binary
  /// asset to disk, and writes the manifest. [onProgress] tracks the binary
  /// download phase only (`completed`/`total` assets) since that's the slow
  /// part — the metadata phase is a handful of small JSON calls.
  Future<CourseDownloadManifest> downloadCourse(
    String courseId, {
    void Function(int completed, int total)? onProgress,
  }) async {
    final response = await ApiClient.dio.get('/courses/$courseId');
    final data = response.data as Map<String, dynamic>;
    final courseJson = (data['data'] ?? data) as Map<String, dynamic>;

    final dir = await _courseDir(courseId);
    await dir.create(recursive: true);

    final rawModules = ((courseJson['modules'] ?? []) as List)
        .cast<Map<String, dynamic>>();

    // Phase A: metadata only — figure out what needs downloading, but don't
    // commit any local path onto a lesson/image/word until phase B confirms
    // the bytes actually landed (otherwise a failed download would leave the
    // manifest pointing at a file that doesn't exist, crashing playback).
    final moduleBuilders = <_ModuleBuilder>[];
    final pendingDownloads = <_PendingAsset>[];

    for (final moduleJson in rawModules) {
      final rawLessons = ((moduleJson['lessons'] ?? []) as List)
          .cast<Map<String, dynamic>>();
      final lessonBuilders = <_LessonBuilder>[];

      for (final lessonJson in rawLessons) {
        final lesson = Lesson.fromJson(lessonJson);

        final images = await _lessonRepository.getLessonImages(lesson.id);
        final vocabulary = await _vocabularyRepository.getVocabulary(
          lessonId: lesson.id,
        );
        final quiz = await _quizRepository.getQuizForLesson(lesson.id);

        String? lessonAudioTarget;
        if (lesson.audioUrl.isNotEmpty) {
          lessonAudioTarget = _assetPath(
            dir,
            'lesson_${lesson.id}_audio${_extensionFor(lesson.audioUrl)}',
          );
          pendingDownloads.add(_PendingAsset(lesson.audioUrl, lessonAudioTarget));
        }

        final imageTargets = <String, String>{};
        for (final image in images) {
          if (image.imageUrl.isEmpty) continue;
          final target = _assetPath(
            dir,
            'lesson_${lesson.id}_image_${image.id}${_extensionFor(image.imageUrl)}',
          );
          imageTargets[image.id] = target;
          pendingDownloads.add(_PendingAsset(image.imageUrl, target));
        }

        final vocabTargets = <String, String>{};
        for (final word in vocabulary) {
          final audioUrl = word.audioUrl;
          if (audioUrl == null || audioUrl.isEmpty) continue;
          final target = _assetPath(
            dir,
            'vocab_${word.id}_audio${_extensionFor(audioUrl)}',
          );
          vocabTargets[word.id] = target;
          pendingDownloads.add(_PendingAsset(audioUrl, target));
        }

        lessonBuilders.add(
          _LessonBuilder(
            lesson: lesson,
            images: images,
            vocabulary: vocabulary,
            quiz: quiz,
            lessonAudioTarget: lessonAudioTarget,
            imageTargets: imageTargets,
            vocabTargets: vocabTargets,
          ),
        );
      }

      moduleBuilders.add(_ModuleBuilder(moduleJson: moduleJson, lessons: lessonBuilders));
    }

    // Phase B: the actual binary downloads — the slow part, so this is what
    // `onProgress` tracks. Only paths that succeed here make it into the
    // final manifest.
    final total = pendingDownloads.length;
    var completed = 0;
    final succeeded = <String>{};
    onProgress?.call(completed, total);
    for (final asset in pendingDownloads) {
      final ok = await _downloadAsset(asset.remoteUrl, File(asset.localPath));
      if (ok) succeeded.add(asset.localPath);
      completed++;
      onProgress?.call(completed, total);
    }

    // Phase C: assemble the manifest, only keeping local paths that
    // downloaded successfully.
    final modules = moduleBuilders.map((moduleBuilder) {
      final moduleJson = moduleBuilder.moduleJson;
      final lessons = moduleBuilder.lessons.map((lessonBuilder) {
        final lessonAudioTarget = lessonBuilder.lessonAudioTarget;
        return OfflineLesson(
          lesson: lessonBuilder.lesson,
          localAudioPath:
              (lessonAudioTarget != null && succeeded.contains(lessonAudioTarget))
                  ? lessonAudioTarget
                  : null,
          images: lessonBuilder.images.map((image) {
            final target = lessonBuilder.imageTargets[image.id];
            return OfflineLessonImage(
              image: image,
              localPath: (target != null && succeeded.contains(target)) ? target : null,
            );
          }).toList(),
          vocabulary: lessonBuilder.vocabulary.map((word) {
            final target = lessonBuilder.vocabTargets[word.id];
            return OfflineVocabularyWord(
              word: word,
              localAudioPath: (target != null && succeeded.contains(target)) ? target : null,
            );
          }).toList(),
          quiz: lessonBuilder.quiz,
        );
      }).toList();

      return OfflineModule(
        id: moduleJson['id'] ?? '',
        title: moduleJson['title'] ?? '',
        description: moduleJson['description'] ?? '',
        frenchTitle: moduleJson['frenchTitle'],
        frenchDescription: moduleJson['frenchDescription'],
        orderNumber: (moduleJson['orderNumber'] as num?)?.toInt() ?? 0,
        lessons: lessons,
      );
    }).toList();

    final manifest = CourseDownloadManifest(
      courseId: courseId,
      title: courseJson['title'] ?? '',
      description: courseJson['description'] ?? '',
      frenchTitle: courseJson['frenchTitle'],
      frenchDescription: courseJson['frenchDescription'],
      level: (courseJson['level'] ?? '').toString(),
      downloadedAt: DateTime.now(),
      modules: modules,
    );

    final manifestFile = await _manifestFile(courseId);
    await manifestFile.writeAsString(jsonEncode(manifest.toJson()));
    await _addToIndex(courseId);

    return manifest;
  }
}
