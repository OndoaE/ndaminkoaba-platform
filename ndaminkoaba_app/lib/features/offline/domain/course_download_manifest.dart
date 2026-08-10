import '../../lessons/domain/lesson.dart';
import '../../lessons/domain/models/lesson_image.dart';
import '../../quiz/domain/quiz.dart';
import '../../vocabulary/domain/vocabulary_word.dart';

/// A downloaded lesson image plus where its bytes landed on disk. [localPath]
/// is null when the image metadata downloaded fine but the binary fetch
/// itself failed (e.g. connection dropped mid-course-download) — the image
/// is then skipped when rendering offline rather than treated as fatal.
class OfflineLessonImage {
  const OfflineLessonImage({required this.image, this.localPath});

  final LessonImage image;
  final String? localPath;

  Map<String, dynamic> toJson() => {
    'image': {
      'id': image.id,
      'lessonId': image.lessonId,
      'imageUrl': image.imageUrl,
      'word': image.word,
      'caption': image.caption,
      'orderNumber': image.orderNumber,
    },
    'localPath': localPath,
  };

  factory OfflineLessonImage.fromJson(Map<String, dynamic> json) {
    return OfflineLessonImage(
      image: LessonImage.fromJson(json['image'] as Map<String, dynamic>),
      localPath: json['localPath'] as String?,
    );
  }
}

/// A downloaded vocabulary word plus its local audio file, if it has one.
class OfflineVocabularyWord {
  const OfflineVocabularyWord({required this.word, this.localAudioPath});

  final VocabularyWord word;
  final String? localAudioPath;

  Map<String, dynamic> toJson() => {
    'word': {
      'id': word.id,
      'word': word.word,
      'frenchMeaning': word.frenchMeaning,
      'englishMeaning': word.englishMeaning,
      'exampleSentence': word.exampleSentence,
      'difficulty': word.difficulty,
      'categoryName': word.categoryName,
      'phoneticTranscription': word.phoneticTranscription,
      'audioUrl': word.audioUrl,
    },
    'localAudioPath': localAudioPath,
  };

  factory OfflineVocabularyWord.fromJson(Map<String, dynamic> json) {
    return OfflineVocabularyWord(
      word: VocabularyWord.fromJson(json['word'] as Map<String, dynamic>),
      localAudioPath: json['localAudioPath'] as String?,
    );
  }
}

/// A fully downloaded lesson: the real [Lesson] (full markdown content,
/// French content, conversation dialogue — everything `GET /lessons/:id`
/// would return, not the thin nav-list shape `CourseDetailLesson` uses),
/// its local audio file if any, and everything else a learner sees on the
/// lesson screen. [quiz] is text-only (question/choice text, never
/// `isCorrect`) purely for the non-scored "Quick Check" preview — taking
/// the real quiz always requires connectivity, see `lesson_screen.dart`.
class OfflineLesson {
  const OfflineLesson({
    required this.lesson,
    this.localAudioPath,
    this.images = const [],
    this.vocabulary = const [],
    this.quiz,
  });

  final Lesson lesson;
  final String? localAudioPath;
  final List<OfflineLessonImage> images;
  final List<OfflineVocabularyWord> vocabulary;
  final Quiz? quiz;

  Map<String, dynamic> toJson() => {
    'lesson': {
      'id': lesson.id,
      'moduleId': lesson.moduleId,
      'title': lesson.title,
      'summary': lesson.summary,
      'content': lesson.content,
      'frenchTitle': lesson.frenchTitle,
      'frenchSummary': lesson.frenchSummary,
      'frenchContent': lesson.frenchContent,
      'audioUrl': lesson.audioUrl,
      'videoUrl': lesson.videoUrl,
      'orderNumber': lesson.orderNumber,
      'conversationJson': lesson.conversation
          .map(
            (c) => {
              'speaker': c.speaker,
              'text': c.text,
              'frenchText': c.frenchText,
            },
          )
          .toList(),
    },
    'localAudioPath': localAudioPath,
    'images': images.map((i) => i.toJson()).toList(),
    'vocabulary': vocabulary.map((v) => v.toJson()).toList(),
    // Reuse the raw quiz JSON shape `Quiz.fromJson` already expects —
    // question/choice text only, no `isCorrect` ever present upstream.
    'quiz': quiz == null
        ? null
        : {
            'id': quiz!.id,
            'title': quiz!.title,
            'description': quiz!.description,
            'frenchTitle': quiz!.frenchTitle,
            'frenchDescription': quiz!.frenchDescription,
            'passingScore': quiz!.passingScore,
            'questions': quiz!.questions
                .map(
                  (q) => {
                    'id': q.id,
                    'questionText': q.questionText,
                    'explanation': q.explanation,
                    'frenchQuestionText': q.frenchQuestionText,
                    'frenchExplanation': q.frenchExplanation,
                    'choices': q.choices
                        .map(
                          (c) => {
                            'id': c.id,
                            'choiceText': c.choiceText,
                            'frenchChoiceText': c.frenchChoiceText,
                          },
                        )
                        .toList(),
                  },
                )
                .toList(),
          },
  };

  factory OfflineLesson.fromJson(Map<String, dynamic> json) {
    final quizJson = json['quiz'] as Map<String, dynamic>?;
    return OfflineLesson(
      lesson: Lesson.fromJson(json['lesson'] as Map<String, dynamic>),
      localAudioPath: json['localAudioPath'] as String?,
      images: ((json['images'] ?? []) as List)
          .map((e) => OfflineLessonImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      vocabulary: ((json['vocabulary'] ?? []) as List)
          .map((e) => OfflineVocabularyWord.fromJson(e as Map<String, dynamic>))
          .toList(),
      quiz: quizJson == null ? null : Quiz.fromJson(quizJson),
    );
  }
}

class OfflineModule {
  const OfflineModule({
    required this.id,
    required this.title,
    required this.description,
    this.frenchTitle,
    this.frenchDescription,
    required this.orderNumber,
    required this.lessons,
  });

  final String id;
  final String title;
  final String description;
  final String? frenchTitle;
  final String? frenchDescription;
  final int orderNumber;
  final List<OfflineLesson> lessons;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'frenchTitle': frenchTitle,
    'frenchDescription': frenchDescription,
    'orderNumber': orderNumber,
    'lessons': lessons.map((l) => l.toJson()).toList(),
  };

  factory OfflineModule.fromJson(Map<String, dynamic> json) {
    return OfflineModule(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchDescription: json['frenchDescription'],
      orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 0,
      lessons: ((json['lessons'] ?? []) as List)
          .map((e) => OfflineLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// The on-disk record of one downloaded course — everything
/// `course_detail_screen.dart`/`lesson_screen.dart`/the vocabulary screen
/// need to keep working with zero connectivity, plus enough metadata to
/// show a "downloaded on ..." indicator and support removal.
class CourseDownloadManifest {
  const CourseDownloadManifest({
    required this.courseId,
    required this.title,
    required this.description,
    this.frenchTitle,
    this.frenchDescription,
    required this.level,
    required this.downloadedAt,
    required this.modules,
  });

  final String courseId;
  final String title;
  final String description;
  final String? frenchTitle;
  final String? frenchDescription;
  final String level;
  final DateTime downloadedAt;
  final List<OfflineModule> modules;

  int get lessonCount => modules.fold(0, (sum, m) => sum + m.lessons.length);

  /// Flattened, course-order lesson list — mirrors the ordering logic
  /// `course_detail_screen.dart` already applies to the live data.
  List<OfflineLesson> get orderedLessons {
    final sortedModules = [...modules]
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    return sortedModules
        .expand(
          (m) => [...m.lessons]
            ..sort(
              (a, b) => a.lesson.orderNumber.compareTo(b.lesson.orderNumber),
            ),
        )
        .toList();
  }

  OfflineLesson? findLesson(String lessonId) {
    for (final module in modules) {
      for (final lesson in module.lessons) {
        if (lesson.lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'title': title,
    'description': description,
    'frenchTitle': frenchTitle,
    'frenchDescription': frenchDescription,
    'level': level,
    'downloadedAt': downloadedAt.toIso8601String(),
    'modules': modules.map((m) => m.toJson()).toList(),
  };

  factory CourseDownloadManifest.fromJson(Map<String, dynamic> json) {
    return CourseDownloadManifest(
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchDescription: json['frenchDescription'],
      level: (json['level'] ?? '').toString(),
      downloadedAt:
          DateTime.tryParse(json['downloadedAt'] ?? '') ?? DateTime.now(),
      modules: ((json['modules'] ?? []) as List)
          .map((e) => OfflineModule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
