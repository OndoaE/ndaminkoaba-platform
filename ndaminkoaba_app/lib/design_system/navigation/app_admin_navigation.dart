import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../shadows/app_shadows.dart';
import '../spacing/app_spacing.dart';

/// Admin equivalent of `AppBottomNavigation` — same floating pill treatment
/// so both apps share one navigation language.
class AppAdminNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppAdminNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: "Dashboard",
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: "Users",
            ),
            NavigationDestination(
              icon: Icon(Icons.language_outlined),
              selectedIcon: Icon(Icons.language),
              label: "Languages",
            ),
            NavigationDestination(
              icon: Icon(Icons.workspace_premium_outlined),
              selectedIcon: Icon(Icons.workspace_premium),
              label: "Certificates",
            ),
          ],
        ),
      ),
    );
  }
}
