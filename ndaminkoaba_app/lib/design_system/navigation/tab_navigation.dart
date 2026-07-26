import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Central mapping from the 5 learner bottom-nav tabs (Home / Learn /
/// Practice / AI Tutor / Profile) to their top-level routes, so every
/// screen that shows [AppBottomNavigation] navigates the same way instead
/// of re-implementing the switch.
void handleTabTap(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go('/dashboard');
      break;
    case 1:
      context.go('/learn');
      break;
    case 2:
      context.go('/practice');
      break;
    case 3:
      context.go('/nnanga');
      break;
    case 4:
      context.go('/profile');
      break;
  }
}

/// Same idea for the 4-tab administrator shell.
void handleAdminTabTap(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go('/admin');
      break;
    case 1:
      context.go('/admin/users');
      break;
    case 2:
      context.go('/admin/languages');
      break;
    case 3:
      context.go('/admin/certificates');
      break;
  }
}
