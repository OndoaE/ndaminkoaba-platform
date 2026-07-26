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
              icon: _AnimatedNavIcon(
                outlineIcon: Icons.home_outlined,
                filledIcon: Icons.home,
                selected: currentIndex == 0,
              ),
              selectedIcon: _AnimatedNavIcon(
                outlineIcon: Icons.home_outlined,
                filledIcon: Icons.home,
                selected: currentIndex == 0,
              ),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: _AnimatedNavIcon(
                outlineIcon: Icons.menu_book_outlined,
                filledIcon: Icons.menu_book,
                selected: currentIndex == 1,
              ),
              selectedIcon: _AnimatedNavIcon(
                outlineIcon: Icons.menu_book_outlined,
                filledIcon: Icons.menu_book,
                selected: currentIndex == 1,
              ),
              label: l10n.navLearn,
            ),
            NavigationDestination(
              icon: _AnimatedNavIcon(
                outlineIcon: Icons.bolt_outlined,
                filledIcon: Icons.bolt,
                selected: currentIndex == 2,
              ),
              selectedIcon: _AnimatedNavIcon(
                outlineIcon: Icons.bolt_outlined,
                filledIcon: Icons.bolt,
                selected: currentIndex == 2,
              ),
              label: l10n.navPractice,
            ),
            NavigationDestination(
              icon: _AnimatedNavImageIcon(selected: currentIndex == 3),
              selectedIcon: _AnimatedNavImageIcon(selected: currentIndex == 3),
              label: l10n.navAI,
            ),
            NavigationDestination(
              icon: _AnimatedNavIcon(
                outlineIcon: Icons.person_outline,
                filledIcon: Icons.person,
                selected: currentIndex == 4,
              ),
              selectedIcon: _AnimatedNavIcon(
                outlineIcon: Icons.person_outline,
                filledIcon: Icons.person,
                selected: currentIndex == 4,
              ),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

/// Both `icon` and `selectedIcon` slots on a [NavigationDestination] are set
/// to the *same* instance of this widget (see [AppBottomNavigation.build]),
/// so Material's own built-in crossfade between those two slots becomes a
/// no-op — the actual bounce-and-morph motion below is what the learner
/// sees, driven entirely by [selected] rather than by which slot the
/// framework currently renders.
class _AnimatedNavIcon extends StatelessWidget {
  const _AnimatedNavIcon({
    required this.outlineIcon,
    required this.filledIcon,
    required this.selected,
  });

  final IconData outlineIcon;
  final IconData filledIcon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          selected ? filledIcon : outlineIcon,
          key: ValueKey<bool>(selected),
        ),
      ),
    );
  }
}

/// Same bounce treatment as [_AnimatedNavIcon], adapted for the Nnanga tab's
/// custom PNG mark (no separate outline/filled artwork exists for it, so
/// selection is conveyed by scale + opacity instead of a glyph swap).
class _AnimatedNavImageIcon extends StatelessWidget {
  const _AnimatedNavImageIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: selected ? 1.0 : 0.55,
        duration: const Duration(milliseconds: 200),
        child: Image.asset(
          'assets/icons/nnanga_ai_icon_circle.png',
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}
