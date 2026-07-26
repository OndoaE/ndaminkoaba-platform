import 'package:flutter/material.dart';

import '../../../design_system/gradients/app_gradients.dart';

/// Visual theme for a certificate, keyed off the course level — mirrors the
/// backend PDF template one-for-one: Beginner=green/1 star,
/// Intermediate=red/2 stars, Advanced=yellow/3 stars.
class CertificateLevelTheme {
  const CertificateLevelTheme({required this.gradient, required this.starCount});

  final Gradient gradient;
  final int starCount;
}

CertificateLevelTheme certificateThemeForLevel(String level) {
  switch (level.toUpperCase()) {
    case 'INTERMEDIATE':
      return const CertificateLevelTheme(
        gradient: AppGradients.certificateIntermediate,
        starCount: 2,
      );
    case 'ADVANCED':
      return const CertificateLevelTheme(
        gradient: AppGradients.certificateAdvanced,
        starCount: 3,
      );
    case 'BEGINNER':
    default:
      return const CertificateLevelTheme(
        gradient: AppGradients.primary,
        starCount: 1,
      );
  }
}
