import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/storage_service.dart';
import '../domain/models/login_response.dart';

/// Shared by the email/password and OAuth sign-in paths on both the login
/// and register screens, so "where does a learner land after auth" only
/// has one definition.
Future<void> saveLoginSession(LoginResponse result) async {
  await StorageService.saveToken(result.accessToken);
  await StorageService.saveUserId(result.id);
  await StorageService.saveFullName(result.fullName);
  await StorageService.saveRole(result.role);
  await StorageService.saveEmail(result.email);
}

Future<void> navigateAfterLogin(
  BuildContext context,
  LoginResponse result, {
  required void Function(String message) showMessage,
}) async {
  if (result.role == 'ADMIN') {
    context.go('/admin');
    return;
  }
  if (result.isFirstLogin) {
    context.go('/welcome', extra: result.fullName);
    return;
  }

  final learningLanguageId = await StorageService.getLearningLanguageId();
  if (!context.mounted) return;
  if (learningLanguageId == null) {
    context.go('/select-learning-language');
    return;
  }

  // A returning learner who already has a language picked gets a chance to
  // continue it or switch, rather than being dropped straight onto the
  // dashboard — see `ContinueLearningScreen`.
  context.go('/continue-learning', extra: learningLanguageId);
}
