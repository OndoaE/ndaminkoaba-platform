import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';
import '../widgets/nda_floral_decoration.dart';

class _LearnerNavItem {
  const _LearnerNavItem(this.key, this.label, this.icon, this.route);

  final String key;
  final String label;
  final IconData icon;
  final String route;
}

/// The persistent green left sidebar for the learner app — replaces
/// [AppBottomNavigation] entirely (mockup-driven decision, applies at every
/// screen width, not just wide layouts; see [LearnerShell] for the
/// responsive drawer fallback below 900px).
class LearnerSidebar extends StatelessWidget {
  const LearnerSidebar({
    super.key,
    required this.activeNavKey,
    this.onNavigate,
  });

  final String activeNavKey;

  /// Called after navigating — used by [LearnerShell] to close the drawer
  /// on narrow layouts. Null in the persistent-sidebar case.
  final VoidCallback? onNavigate;

  List<_LearnerNavItem> _items(AppLocalizations l10n) => [
    _LearnerNavItem(
      'home',
      l10n.learnerNavHome,
      Icons.home_outlined,
      '/dashboard',
    ),
    _LearnerNavItem(
      'my_courses',
      l10n.learnerNavMyCourses,
      Icons.menu_book_outlined,
      '/my-learning',
    ),
    _LearnerNavItem(
      'library',
      l10n.learnerNavLibrary,
      Icons.local_library_outlined,
      '/books',
    ),
    _LearnerNavItem(
      'lessons',
      l10n.learnerNavLessons,
      Icons.description_outlined,
      '/lessons',
    ),
    _LearnerNavItem(
      'vocabulary',
      l10n.learnerNavVocabulary,
      Icons.translate_outlined,
      '/vocabulary',
    ),
    _LearnerNavItem(
      'ai_tutor',
      l10n.learnerNavAiTutor,
      Icons.smart_toy_outlined,
      '/nnanga',
    ),
    _LearnerNavItem(
      'favorites',
      l10n.learnerNavFavorites,
      Icons.bookmark_outline,
      '/bookmarks',
    ),
    _LearnerNavItem(
      'history',
      l10n.learnerNavHistory,
      Icons.history_outlined,
      '/history',
    ),
    _LearnerNavItem(
      'settings',
      l10n.learnerNavSettings,
      Icons.settings_outlined,
      '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: onNavigate != null
          ? 280
          : (MediaQuery.sizeOf(context).width >= 1400 ? 318 : 270),
      color: AppColors.veryDarkGreen,
      child: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              left: -80,
              bottom: -60,
              child: NdaFloralDecoration(
                corner: Alignment.bottomLeft,
                size: 480,
                opacity: 0.85,
                fadeStop: 0.75,
              ),
            ),
            const Positioned(
              top: -60,
              right: -120,
              child: NdaFloralDecoration(
                corner: Alignment.topRight,
                size: 300,
                opacity: 0.35,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/ndaminkoaba_logo.png',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.secondary,
                            child: Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'NdaMinkoaba',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              l10n.learnerShellTagline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    children: [
                      for (final item in _items(l10n))
                        _LearnerSidebarTile(
                          item: item,
                          active: item.key == activeNavKey,
                          onNavigate: onNavigate,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Text(
                    l10n.learnerShellQuote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 20,
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnerSidebarTile extends StatelessWidget {
  const _LearnerSidebarTile({
    required this.item,
    required this.active,
    this.onNavigate,
  });

  final _LearnerNavItem item;
  final bool active;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: active ? AppColors.secondary : Colors.transparent,
        borderRadius: AppRadius.circle,
        child: InkWell(
          borderRadius: AppRadius.circle,
          onTap: () {
            onNavigate?.call();
            context.go(item.route);
          },
          hoverColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(item.icon, color: Colors.white, size: 26),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
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
