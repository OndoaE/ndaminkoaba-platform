import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../data/content_repository.dart';
import '../domain/admin_content_models.dart';

class AdminNewQuizScreen extends StatefulWidget {
  const AdminNewQuizScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<AdminNewQuizScreen> createState() => _AdminNewQuizScreenState();
}

class _AdminNewQuizScreenState extends State<AdminNewQuizScreen> {
  final repository = ContentRepository();

  bool isLoading = true;
  List<AdminCourseDetail> courses = [];
  AdminCourseDetail? selectedCourse;
  AdminModule? selectedModule;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final result = await repository.getAllCourses(languageId: widget.languageId);
      if (!mounted) return;
      setState(() {
        courses = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'New Quiz'),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pick the lesson that should get a quiz.',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Breadcrumb(
                      courseTitle: selectedCourse?.title,
                      moduleTitle: selectedModule?.title,
                      onResetCourse: () => setState(() {
                        selectedCourse = null;
                        selectedModule = null;
                      }),
                      onResetModule: () => setState(() => selectedModule = null),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (selectedCourse == null)
                      _tiles(
                        items: courses,
                        titleOf: (c) => c.title,
                        subtitleOf: (c) => '${c.modules.length} modules',
                        trailingOf: (c) => Chip(label: Text(c.level.replaceAll('_', ' '))),
                        onTap: (c) => setState(() => selectedCourse = c),
                        emptyText: 'No courses yet.',
                      )
                    else if (selectedModule == null)
                      _tiles(
                        items: selectedCourse!.modules,
                        titleOf: (m) => m.title,
                        subtitleOf: (m) => '${m.lessons.length} lessons',
                        trailingOf: (_) => null,
                        onTap: (m) => setState(() => selectedModule = m),
                        emptyText: 'This course has no modules yet.',
                      )
                    else
                      _tiles(
                        items: selectedModule!.lessons,
                        titleOf: (l) => l.title,
                        subtitleOf: (l) => l.summary,
                        trailingOf: (_) => const Icon(Icons.quiz_outlined, color: AppColors.primary),
                        onTap: (lesson) => context.pushReplacement(
                          '/admin/lessons/${lesson.id}/quiz',
                          extra: lesson.title,
                        ),
                        emptyText: 'This module has no lessons yet — add one first.',
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _tiles<T>({
    required List<T> items,
    required String Function(T) titleOf,
    required String Function(T) subtitleOf,
    required Widget? Function(T) trailingOf,
    required ValueChanged<T> onTap,
    required String emptyText,
  }) {
    if (items.isEmpty) {
      return PremiumCard(child: Text(emptyText, style: AppTypography.caption));
    }

    return Column(
      children: items.map((item) {
        final trailing = trailingOf(item);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => onTap(item),
            child: PremiumCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titleOf(item), style: AppTypography.title),
                        Text(
                          subtitleOf(item),
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing,
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({
    required this.courseTitle,
    required this.moduleTitle,
    required this.onResetCourse,
    required this.onResetModule,
  });

  final String? courseTitle;
  final String? moduleTitle;
  final VoidCallback onResetCourse;
  final VoidCallback onResetModule;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: onResetCourse,
          child: Text(
            'Course',
            style: AppTypography.title.copyWith(
              color: courseTitle == null ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
        if (courseTitle != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ),
          InkWell(
            onTap: onResetModule,
            child: Text(
              courseTitle!,
              style: AppTypography.title.copyWith(
                color: moduleTitle == null ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
        if (moduleTitle != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ),
          Text(moduleTitle!, style: AppTypography.title.copyWith(color: AppColors.primary)),
        ],
      ],
    );
  }
}
