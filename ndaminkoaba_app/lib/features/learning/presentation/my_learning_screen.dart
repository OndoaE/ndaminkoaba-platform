import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../core/locale/localized_text.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/app_bottom_navigation.dart';
import '../../../design_system/navigation/tab_navigation.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/data/enrollment_repository.dart';
import '../../courses/domain/models/enrolled_course.dart';

Color _levelColor(String level) {
  switch (level) {
    case 'BEGINNER':
      return AppColors.primary;
    case 'INTERMEDIATE':
      return AppColors.secondary;
    case 'ADVANCED':
      return const Color(0xFF3D6BE0);
    default:
      return AppColors.primary;
  }
}

IconData _levelIcon(String level) {
  switch (level) {
    case 'BEGINNER':
      return Icons.looks_one_outlined;
    case 'INTERMEDIATE':
      return Icons.looks_two_outlined;
    case 'ADVANCED':
      return Icons.looks_3_outlined;
    default:
      return Icons.menu_book_outlined;
  }
}

class MyLearningScreen extends ConsumerStatefulWidget {
  const MyLearningScreen({super.key});

  @override
  ConsumerState<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends ConsumerState<MyLearningScreen> {
  final repository = EnrollmentRepository();

  bool isLoading = true;
  List<EnrolledCourse> inProgress = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        if (!mounted) return;
        setState(() => isLoading = false);
        return;
      }

      final enrollments = await repository.getMyEnrollments(userId);
      if (!mounted) return;
      setState(() {
        inProgress = enrollments.where((e) => e.status == 'ACTIVE').toList();
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
        onTap: (index) => handleTabTap(context, index),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.myLearningTitle,
                  style: AppTypography.h1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.myLearningSubtitle, style: AppTypography.caption),
                const SizedBox(height: AppSpacing.xl),
                if (isLoading)
                  const ShimmerListLoader(itemCount: 3, itemHeight: 108)
                else if (inProgress.isEmpty)
                  EmptyState(
                    icon: Icons.school_outlined,
                    title: l10n.myLearningEmptyTitle,
                    message: l10n.myLearningEmptyMessage,
                  )
                else
                  ...inProgress.map(
                    (course) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: InkWell(
                        borderRadius: AppRadius.large,
                        onTap: () =>
                            context.push('/courses/${course.courseId}'),
                        child: _InProgressCard(
                          course: course,
                          isFrench: isFrench,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InProgressCard extends StatelessWidget {
  const _InProgressCard({required this.course, required this.isFrench});

  final EnrolledCourse course;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = _levelColor(course.level);

    return PremiumCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.medium,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(_levelIcon(course.level), color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedText(course.title, course.frenchTitle, isFrench),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: course.progress / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.progressPercentLabel(course.progress),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
