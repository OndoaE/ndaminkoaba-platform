import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import 'learner_sidebar.dart';

/// Responsive learner-app chrome — persistent [LearnerSidebar] at 900px+
/// (matching [AdminShell]'s breakpoint), a hamburger-triggered [Drawer]
/// below it. This fully replaces [AppBottomNavigation] on every screen
/// width, including phones (an explicit product decision — the sidebar
/// nav set is richer than the old 5-tab bar and shouldn't only exist on
/// wide screens). Wrapped screens keep rendering their own [AppHeader] etc.
/// inside [child] — this shell only supplies the sidebar/drawer and, on
/// narrow layouts, a minimal hamburger row above the screen's own content.
class LearnerShell extends StatelessWidget {
  const LearnerShell({super.key, required this.activeNavKey, required this.child});

  final String activeNavKey;
  final Widget child;

  static const _breakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _breakpoint) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                LearnerSidebar(activeNavKey: activeNavKey),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: Drawer(
            width: 248,
            backgroundColor: AppColors.primary,
            child: Builder(
              builder: (drawerContext) => LearnerSidebar(
                activeNavKey: activeNavKey,
                onNavigate: () => Navigator.of(drawerContext).pop(),
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, 0),
                  child: Row(
                    children: [
                      Builder(
                        builder: (barContext) => IconButton(
                          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                          onPressed: () => Scaffold.of(barContext).openDrawer(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        );
      },
    );
  }
}
