import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/locale/localized_text.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/inputs/premium_textfield.dart';
import '../../../design_system/navigation/app_bottom_navigation.dart';
import '../../../design_system/navigation/tab_navigation.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_hero_card.dart';
import '../../../design_system/widgets/section_title.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/course_repository.dart';
import '../domain/models/course.dart';
import 'package:go_router/go_router.dart';

const _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

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

/// The level a learner must finish before [level] unlocks, or null if
/// [level] is already the first one (Beginner).
String? _previousLevel(String level) {
  const order = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];
  final index = order.indexOf(level);
  if (index <= 0) return null;
  return order[index - 1];
}

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  final repository = CourseRepository();
  final searchController = TextEditingController();

  String? selectedLevel;
  String searchQuery = '';
  bool isLoading = true;
  List<Course> courses = [];
  Set<String> unlockedLevels = {'BEGINNER'};

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Course> get _visibleCourses {
    if (searchQuery.isEmpty) return courses;
    final query = searchQuery.toLowerCase();
    return courses
        .where(
          (course) =>
              course.title.toLowerCase().contains(query) ||
              (course.frenchTitle?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final userId = await StorageService.getUserId();
      final languageId = ref.read(currentLearningLanguageProvider);
      final results = await Future.wait([
        repository.getCourses(level: selectedLevel, languageId: languageId),
        if (userId != null) repository.getUnlockedLevels(userId, languageId: languageId),
      ]);

      if (!mounted) return;
      setState(() {
        courses = results[0] as List<Course>;
        if (userId != null) {
          unlockedLevels = results[1] as Set<String>;
        }
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _showLevelLocked(String level) {
    final l10n = AppLocalizations.of(context);
    final previous = _previousLevel(level);
    if (previous == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.levelLockedMessage(_levelLabel(l10n, previous))),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) => handleTabTap(context, index),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientHeroCard(
                gradient: AppGradients.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.coursesTitle,
                      style: AppTypography.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.coursesSubtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PremiumTextField(
                hint: l10n.searchCoursesHint,
                controller: searchController,
                prefixIcon: Icons.search,
                onChanged: (value) => setState(() => searchQuery = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _LevelChip(
                      label: l10n.levelAllLabel,
                      selected: selectedLevel == null,
                      onTap: () {
                        setState(() => selectedLevel = null);
                        load();
                      },
                    ),
                    ..._levels.map(
                      (level) => Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: _LevelChip(
                          label: _levelLabel(l10n, level),
                          selected: selectedLevel == level,
                          onTap: () {
                            setState(() => selectedLevel = level);
                            load();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionTitle(
                title: l10n.availableCoursesTitle,
                subtitle: l10n.availableCoursesSubtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (isLoading)
                const ShimmerListLoader(itemCount: 3, itemHeight: 108)
              else if (_visibleCourses.isEmpty)
                EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: l10n.noCoursesTitle,
                  message: l10n.noCoursesMessage,
                )
              else
                ..._visibleCourses.map((course) {
                  final locked = !unlockedLevels.contains(course.level);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: locked
                          ? () => _showLevelLocked(course.level)
                          : () => context.push('/courses/${course.id}'),
                      child: _CourseCard(
                        course: course,
                        locked: locked,
                        isFrench: isFrench,
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      showCheckmark: false,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? AppColors.primary : Colors.black12),
      ),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    this.locked = false,
    required this.isFrench,
  });

  final Course course;
  final bool locked;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = locked ? AppColors.textSecondary : _levelColor(course.level);
    final title = localizedText(course.title, course.frenchTitle, isFrench);
    final description = localizedText(
      course.description,
      course.frenchDescription,
      isFrench,
    );

    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: PremiumCard(
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
              child: Icon(
                locked ? Icons.lock_outline : _levelIcon(course.level),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.title),
                  const SizedBox(height: AppSpacing.sm),
                  Text(description, style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            _levelLabel(l10n, course.level),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          l10n.lessonsCountLabel(course.lessons),
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              locked ? Icons.lock : Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
