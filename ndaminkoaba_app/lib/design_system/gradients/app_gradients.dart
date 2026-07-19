import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

/// Centralizes the gradients that used to be copy-pasted `LinearGradient`
/// literals across dashboard/courses/admin screens, so every hero banner
/// shares one exact set of colors instead of subtly-drifting duplicates.
class AppGradients {
  AppGradients._();

  static const primary = LinearGradient(
    colors: [AppColors.primary, Color(0xFF0D7A4C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const ai = LinearGradient(
    colors: [AppColors.ai, Color(0xFF6B4CE0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gold = LinearGradient(
    colors: [AppColors.secondary, Color(0xFFE0BE5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Used for Scripture/Bible surfaces — a deep maroon reminiscent of
  /// leather-bound Bibles, distinct from the green/gold brand accents used
  /// for courses and certificates elsewhere in the app.
  static const scripture = LinearGradient(
    colors: [Color(0xFF8B3A3A), Color(0xFFB5544F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
