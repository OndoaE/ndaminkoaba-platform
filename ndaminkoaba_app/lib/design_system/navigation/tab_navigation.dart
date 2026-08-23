import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
