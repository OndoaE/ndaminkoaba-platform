import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../../config/app_config.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/locale/localized_text.dart';
import '../../../core/network/api_error.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/markdown/nda_markdown_extensions.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/app_header.dart';
import '../../../design_system/widgets/badge_earned_dialog.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gold_corner_pattern.dart';
import '../../../design_system/widgets/pagination_dots.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../badges/domain/badge_entry.dart';
import '../../bookmarks/data/bookmarks_repository.dart';
import '../../courses/data/course_repository.dart';
import '../../courses/domain/models/course_detail.dart';
import '../../offline/data/offline_course_repository.dart';
import '../../offline/domain/course_download_manifest.dart';
import '../../progress/data/progress_repository.dart';
import '../../pronunciation/presentation/pronunciation_recorder.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/domain/quiz.dart';
import '../../vocabulary/data/vocabulary_repository.dart';
import '../../vocabulary/domain/vocabulary_word.dart';
import '../data/lesson_progress_service.dart';
import '../data/lesson_repository.dart';
import '../domain/lesson.dart';
import '../domain/models/lesson_image.dart';

String _levelLabel(AppLocalizations l10n, String level) {
  switch (level) {
    case 'BEGINNER':
      return l10n.levelBeginner;
    case 'INTERMEDIATE':
      return l10n.levelIntermediate;
    case 'ADVANCED':
      return l10n.levelAdvanced;
    default:
      return level;
  }
}

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final repository = LessonRepository();
  final progressService = LessonProgressService();
  final progressRepository = ProgressRepository();
  final quizRepository = QuizRepository();
  final vocabularyRepository = VocabularyRepository();
  final bookmarksRepository = BookmarksRepository();
  final courseRepository = CourseRepository();
  final offlineCourseRepository = OfflineCourseRepository();
  final audioPlayer = AudioPlayer();

  bool isLoading = true;
  bool hasError = false;
  bool isOfflineFallback = false;
  Lesson? lesson;
  List<Lesson> siblingLessons = [];
  Quiz? quiz;
  List<LessonImage> lessonImages = [];
  List<VocabularyWord> vocabulary = [];
  CourseDetail? courseDetail;
  String? parentModuleTitle;
  String? parentModuleFrenchTitle;

  String? offlineLessonAudioPath;
  Map<String, String> offlineImagePaths = {};
  Map<String, String> offlineVocabAudioPaths = {};

  String? userId;
  String? bookmarkId;

  // Quick Check (non-scored preview of the quiz's first question).
  String? quickCheckSelectedChoiceId;

  @override
  void initState() {
    super.initState();
    loadLesson();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> loadLesson() async {
    setState(() {
      isLoading = true;
      hasError = false;
      isOfflineFallback = false;
      quickCheckSelectedChoiceId = null;
    });

    try {
      final fetchedLesson = await repository.getLessonById(widget.lessonId);

      List<Lesson> siblings = [fetchedLesson];
      try {
        siblings = await repository.getLessonsByModule(fetchedLesson.moduleId);
        siblings.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
      } catch (_) {
        siblings = [fetchedLesson];
      }

      Quiz? fetchedQuiz;
      try {
        fetchedQuiz = await quizRepository.getQuizForLesson(widget.lessonId);
      } catch (_) {
        fetchedQuiz = null;
      }

      List<LessonImage> fetchedImages = [];
      try {
        fetchedImages = await repository.getLessonImages(widget.lessonId);
      } catch (_) {
        fetchedImages = [];
      }

      List<VocabularyWord> fetchedVocabulary = [];
      try {
        fetchedVocabulary = await vocabularyRepository.getVocabulary(
          lessonId: widget.lessonId,
        );
      } catch (_) {
        fetchedVocabulary = [];
      }

      CourseDetail? fetchedCourseDetail;
      String? moduleTitle;
      String? moduleFrenchTitle;
      try {
        fetchedCourseDetail = await courseRepository.getCourseDetail(
          widget.courseId,
        );
        for (final module in fetchedCourseDetail.modules) {
          if (module.lessons.any((l) => l.id == widget.lessonId)) {
            moduleTitle = module.title;
            moduleFrenchTitle = module.frenchTitle;
            break;
          }
        }
      } catch (_) {
        fetchedCourseDetail = null;
      }

      final fetchedUserId = await StorageService.getUserId();
      String? fetchedBookmarkId;
      if (fetchedUserId != null) {
        try {
          fetchedBookmarkId = await bookmarksRepository.findBookmarkId(
            userId: fetchedUserId,
            lessonId: widget.lessonId,
          );
        } catch (_) {
          fetchedBookmarkId = null;
        }
      }

      if (!mounted) return;

      setState(() {
        lesson = fetchedLesson;
        siblingLessons = siblings;
        quiz = fetchedQuiz;
        lessonImages = fetchedImages;
        vocabulary = fetchedVocabulary;
        courseDetail = fetchedCourseDetail;
        parentModuleTitle = moduleTitle;
        parentModuleFrenchTitle = moduleFrenchTitle;
        userId = fetchedUserId;
        bookmarkId = fetchedBookmarkId;
        isLoading = false;
      });
    } catch (e) {
      final isConnectivityIssue =
          !kIsWeb && e is DioException && isConnectivityFailure(e);
      if (isConnectivityIssue && await _loadFromOfflineCache()) return;

      if (!mounted) return;

      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  /// Falls back to the downloaded copy (if any) when the live fetch fails
  /// for connectivity reasons. Returns whether a cached lesson was found
  /// and rendered. Sibling navigation is scoped to the lesson's own module
  /// within the manifest, matching `getLessonsByModule`'s live behavior.
  /// Bookmarks aren't cached (toggling them needs connectivity anyway), so
  /// they're left unset offline.
  Future<bool> _loadFromOfflineCache() async {
    final manifest = await offlineCourseRepository.loadManifest(
      widget.courseId,
    );
    if (manifest == null) return false;

    final offlineLesson = manifest.findLesson(widget.lessonId);
    if (offlineLesson == null) return false;

    final module = manifest.modules.firstWhere(
      (m) => m.id == offlineLesson.lesson.moduleId,
      orElse: () => OfflineModule(
        id: '',
        title: '',
        description: '',
        orderNumber: 0,
        lessons: [offlineLesson],
      ),
    );
    final siblingOfflineLessons = [...module.lessons]
      ..sort((a, b) => a.lesson.orderNumber.compareTo(b.lesson.orderNumber));

    final fetchedUserId = await StorageService.getUserId();

    if (!mounted) return true;

    setState(() {
      lesson = offlineLesson.lesson;
      siblingLessons = siblingOfflineLessons.map((l) => l.lesson).toList();
      quiz = offlineLesson.quiz;
      lessonImages = offlineLesson.images.map((i) => i.image).toList();
      vocabulary = offlineLesson.vocabulary.map((v) => v.word).toList();
      courseDetail = CourseDetail.fromManifest(manifest);
      parentModuleTitle = module.title;
      parentModuleFrenchTitle = module.frenchTitle;
      userId = fetchedUserId;
      bookmarkId = null;
      offlineLessonAudioPath = offlineLesson.localAudioPath;
      offlineImagePaths = {
        for (final image in offlineLesson.images)
          if (image.localPath != null) image.image.id: image.localPath!,
      };
      offlineVocabAudioPaths = {
        for (final word in offlineLesson.vocabulary)
          if (word.localAudioPath != null) word.word.id: word.localAudioPath!,
      };
      isOfflineFallback = true;
      isLoading = false;
    });
    return true;
  }

  Future<void> _toggleBookmark() async {
    final currentUserId = userId;
    if (currentUserId == null) return;

    final existingId = bookmarkId;
    try {
      if (existingId != null) {
        await bookmarksRepository.remove(existingId);
        if (!mounted) return;
        setState(() => bookmarkId = null);
      } else {
        final newId = await bookmarksRepository.create(
          userId: currentUserId,
          lessonId: widget.lessonId,
        );
        if (!mounted) return;
        setState(() => bookmarkId = newId);
      }
    } catch (_) {
      // Bookmarking is a nice-to-have — a failed toggle just leaves the
      // icon state unchanged rather than surfacing an error.
    }
  }

  Future<void> _playAudio(String url, {String? localPath}) async {
    try {
      if (localPath != null && await File(localPath).exists()) {
        await audioPlayer.setFilePath(localPath);
      } else {
        await audioPlayer.setUrl(AppConfig.resolveUrl(url));
      }
      await audioPlayer.play();
    } catch (_) {
      // Playback failures are silently ignored — no audio for this word is
      // a content gap, not something the learner needs an error dialog for.
    }
  }

  /// Marks the current lesson complete (local cache + server) and advances
  /// to the next lesson in the module, or exits the lesson flow if this was
  /// the last one. Shared by the no-quiz "Finish/Next Lesson" button and by
  /// the "Take Quiz" flow once the quiz is passed — passing a quiz is a way
  /// of finishing the lesson, not a separate dead end.
  Future<void> _completeAndAdvance() async {
    final currentLesson = lesson;
    if (currentLesson == null) return;

    final currentUserId = await StorageService.getUserId();

    await progressService.markCompleted(
      courseId: widget.courseId,
      lessonId: currentLesson.id,
    );

    if (currentUserId != null) {
      try {
        await progressRepository.markLessonComplete(
          userId: currentUserId,
          lessonId: currentLesson.id,
        );
      } catch (_) {
        // Local cache above still lets the learner keep moving even if
        // the server call fails.
      }
    }

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.lessonCompletedMessage)));

    final currentIndex = siblingLessons.indexWhere(
      (item) => item.id == currentLesson.id,
    );
    final hasNextLesson =
        currentIndex != -1 && currentIndex < siblingLessons.length - 1;

    if (hasNextLesson) {
      _goToLesson(siblingLessons[currentIndex + 1]);
    } else {
      Navigator.pop(context);
    }
  }

  void _goToLesson(Lesson target) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LessonScreen(courseId: widget.courseId, lessonId: target.id),
      ),
    );
  }

  Future<void> _onBadgesEarned(List<BadgeEntry> badges) async {
    if (!mounted || badges.isEmpty) return;
    await BadgeEarnedDialog.show(context, badges);
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);

            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 2, itemHeight: 140),
              );
            }

            if (hasError || lesson == null) {
              return _LessonNotFound(onRetry: loadLesson);
            }

            final currentLesson = lesson!;
            final currentIndex = siblingLessons.indexWhere(
              (item) => item.id == currentLesson.id,
            );
            final total = siblingLessons.length;
            final hasPreviousLesson = currentIndex > 0;
            final hasNextLesson =
                currentIndex != -1 && currentIndex < total - 1;
            final lessonContent = localizedText(
              currentLesson.content,
              currentLesson.frenchContent,
              isFrench,
            );
            final lessonSummary = localizedText(
              currentLesson.summary,
              currentLesson.frenchSummary,
              isFrench,
            );
            final primaryWord = vocabulary.isNotEmpty ? vocabulary.first : null;
            final levelLabel = courseDetail != null
                ? _levelLabel(l10n, courseDetail!.level)
                : null;
            final rawModuleTitle = parentModuleTitle;
            final moduleTitle = rawModuleTitle != null
                ? localizedText(
                    rawModuleTitle,
                    parentModuleFrenchTitle,
                    isFrench,
                  )
                : null;
            final firstQuestion = quiz?.questions.isNotEmpty == true
                ? quiz!.questions.first
                : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeader(
                    onBack: () => Navigator.pop(context),
                    title: l10n.lessonNumberLabel(currentLesson.orderNumber),
                    trailing: userId != null && !isOfflineFallback
                        ? InkWell(
                            borderRadius: AppRadius.circle,
                            onTap: _toggleBookmark,
                            child: Icon(
                              bookmarkId != null
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: bookmarkId != null
                                  ? AppColors.secondary
                                  : AppColors.textPrimary,
                            ),
                          )
                        : null,
                  ),
                  if (isOfflineFallback) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              l10n.downloadedOfflineLabel,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  if (total > 1) ...[
                    Text(
                      '${currentIndex + 1} of $total',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: (currentIndex + 1) / total,
                        minHeight: 6,
                        backgroundColor: AppColors.progressRingTrack,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  if (levelLabel != null || moduleTitle != null)
                    Text(
                      [levelLabel, moduleTitle].whereType<String>().join(' • '),
                      style: AppTypography.caption,
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  // Hero: today's lesson
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: AppRadius.large,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Stack(
                      children: [
                        const GoldCornerPattern(color: Colors.white),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.todaysLessonLabel,
                                    style: TextStyle(
                                      color: AppColors.secondary.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    localizedText(
                                      currentLesson.title,
                                      currentLesson.frenchTitle,
                                      isFrench,
                                    ),
                                    style: AppTypography.h1.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (lessonSummary.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      lessonSummary,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.forum_outlined,
                              color: Colors.white54,
                              size: 36,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Listen and Repeat
                  if (primaryWord != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.listenAndRepeatTitle,
                            style: AppTypography.title,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              if ((primaryWord.audioUrl ?? '').isNotEmpty)
                                InkWell(
                                  borderRadius: AppRadius.circle,
                                  onTap: () => _playAudio(
                                    primaryWord.audioUrl!,
                                    localPath:
                                        offlineVocabAudioPaths[primaryWord.id],
                                  ),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.volume_up,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      primaryWord.word,
                                      style: AppTypography.h2.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    if ((primaryWord.phoneticTranscription ??
                                            '')
                                        .isNotEmpty)
                                      Text(
                                        '/${primaryWord.phoneticTranscription}/',
                                        style: AppTypography.caption.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    Text(
                                      (isFrench
                                              ? primaryWord.frenchMeaning
                                              : primaryWord.englishMeaning) ??
                                          '',
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.tapSpeakerRepeatCaption,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Your Pronunciation
                  if (primaryWord != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    PronunciationRecorder(
                      targetText: primaryWord.word,
                      vocabularyId: primaryWord.id,
                      lessonId: currentLesson.id,
                      onNewlyEarnedBadges: _onBadgesEarned,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentLesson.audioUrl.isNotEmpty) ...[
                          InkWell(
                            borderRadius: AppRadius.circle,
                            onTap: () => _playAudio(
                              currentLesson.audioUrl,
                              localPath: offlineLessonAudioPath,
                            ),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.volume_up,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        lessonContent.isNotEmpty
                            ? MarkdownBody(
                                data: lessonContent,
                                styleSheet: MarkdownStyleSheet(
                                  p: AppTypography.lessonBody,
                                  strong: AppTypography.lessonBodyStrong,
                                ),
                                softLineBreak: true,
                                inlineSyntaxes: ndaMarkdownInlineSyntaxes,
                                builders: ndaMarkdownBuilders,
                                onTapLink: ndaMarkdownOnTapLink,
                              )
                            : Text(
                                l10n.lessonNoContent,
                                style: AppTypography.lessonBody,
                              ),
                      ],
                    ),
                  ),

                  if (lessonImages.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.illustratedWordsTitle,
                            style: AppTypography.title,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: lessonImages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final image = lessonImages[index];
                                return SizedBox(
                                  width: 110,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: AppRadius.medium,
                                          child:
                                              offlineImagePaths.containsKey(
                                                image.id,
                                              )
                                              ? Image.file(
                                                  File(
                                                    offlineImagePaths[image
                                                        .id]!,
                                                  ),
                                                  width: 110,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        color:
                                                            AppColors.surface,
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Icon(
                                                          Icons
                                                              .broken_image_outlined,
                                                        ),
                                                      ),
                                                )
                                              : Image.network(
                                                  AppConfig.resolveUrl(
                                                    image.imageUrl,
                                                  ),
                                                  width: 110,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        color:
                                                            AppColors.surface,
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Icon(
                                                          Icons
                                                              .broken_image_outlined,
                                                        ),
                                                      ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        image.word,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // In Conversation
                  if (currentLesson.conversation.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.inConversationTitle,
                            style: AppTypography.title,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...currentLesson.conversation.asMap().entries.map((
                            entry,
                          ) {
                            final line = entry.value;
                            final isSecondSpeaker = entry.key % 2 == 1;
                            final avatarColor = isSecondSpeaker
                                ? AppColors.secondary
                                : AppColors.primary;
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: avatarColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: avatarColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSecondSpeaker
                                            ? AppColors.cardAlt
                                            : AppColors.primary.withValues(
                                                alpha: 0.08,
                                              ),
                                        borderRadius: AppRadius.medium,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            line.text,
                                            style: AppTypography.body.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          if (isFrench &&
                                              (line.frenchText ?? '')
                                                  .isNotEmpty)
                                            Text(
                                              line.frenchText!,
                                              style: AppTypography.caption,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  // Quick Check (non-scored preview of the real quiz's first question)
                  if (firstQuestion != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.quickCheckTitle,
                            style: AppTypography.title,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            localizedText(
                              firstQuestion.questionText,
                              firstQuestion.frenchQuestionText,
                              isFrench,
                            ),
                            style: AppTypography.body,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...firstQuestion.choices.map((choice) {
                            final selected =
                                quickCheckSelectedChoiceId == choice.id;
                            final revealed = quickCheckSelectedChoiceId != null;
                            // isCorrect isn't exposed on the learner-facing
                            // QuizChoice model (by design — see quiz_screen),
                            // so this preview only highlights the learner's
                            // own pick, not right/wrong; the real graded
                            // check happens in Take Quiz below.
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: InkWell(
                                borderRadius: AppRadius.medium,
                                onTap: revealed
                                    ? null
                                    : () => setState(
                                        () => quickCheckSelectedChoiceId =
                                            choice.id,
                                      ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : AppColors.surface,
                                    borderRadius: AppRadius.medium,
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.divider,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: selected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          localizedText(
                                            choice.choiceText,
                                            choice.frenchChoiceText,
                                            isFrench,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                  if (quiz != null && isOfflineFallback) ...[
                    PrimaryButton(
                      label: l10n.takeQuizButton,
                      icon: Icons.quiz,
                      onPressed: null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.quizRequiresConnectivityMessage,
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                  ] else if (quiz != null)
                    PrimaryButton(
                      label: l10n.takeQuizButton,
                      icon: Icons.quiz,
                      onPressed: () async {
                        final passed = await context.push<bool>(
                          '/courses/${widget.courseId}/lessons/${currentLesson.id}/quiz',
                        );
                        if (passed == true) {
                          await _completeAndAdvance();
                        }
                      },
                    )
                  else ...[
                    Row(
                      children: [
                        if (hasPreviousLesson)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _goToLesson(siblingLessons[currentIndex - 1]),
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: Text(
                                l10n.previousLessonButton,
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.medium,
                                ),
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        if (total > 1) ...[
                          const SizedBox(width: AppSpacing.sm),
                          PaginationDots(
                            count: total,
                            currentIndex: currentIndex.clamp(0, total - 1),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ] else
                          const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: PrimaryButton(
                            label: hasNextLesson
                                ? l10n.nextLessonButton
                                : l10n.finishLessonButton,
                            icon: hasNextLesson
                                ? Icons.arrow_forward
                                : Icons.check_circle,
                            onPressed: _completeAndAdvance,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LessonNotFound extends StatelessWidget {
  const _LessonNotFound({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          EmptyState(
            icon: Icons.error_outline,
            iconColor: AppColors.error,
            title: l10n.lessonNotFoundTitle,
            message: l10n.lessonNotFoundMessage,
            action: PrimaryButton(label: l10n.commonRetry, onPressed: onRetry),
          ),
        ],
      ),
    );
  }
}
