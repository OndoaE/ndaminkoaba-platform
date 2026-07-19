import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../shadows/app_shadows.dart';
import '../spacing/app_spacing.dart';

/// A floating, rounded "pill" bottom nav — margin on all sides + a soft
/// shadow so it reads as a card hovering over the content, rather than the
/// flat edge-to-edge bar Material gives you by default. The Scaffold's own
/// background shows through the margin gaps, which is what creates the
/// floating look; no other setup is needed at call sites.
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadows.floating,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.extraLarge,
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          indicatorColor: AppColors.secondary.withValues(alpha: 0.25),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 68,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book),
              label: l10n.navCourses,
            ),
            NavigationDestination(
              icon: const Icon(Icons.school_outlined),
              selectedIcon: const Icon(Icons.school),
              label: l10n.navMyLearning,
            ),
            NavigationDestination(
              icon: Opacity(
                opacity: 0.55,
                child: Image.asset('assets/icons/nnanga_ai_icon_circle.png', width: 24, height: 24),
              ),
              selectedIcon: Image.asset('assets/icons/nnanga_ai_icon_circle.png', width: 24, height: 24),
              label: l10n.navAI,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
