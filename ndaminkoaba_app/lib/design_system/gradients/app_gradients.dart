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

  /// Certificate level themes — mirrors the per-level palette in the
  /// backend's PDF template (`backend-api/src/certificates/pdf/pdf.service.ts`).
  /// Beginner reuses [primary] (green); these two are certificate-specific
  /// so they don't couple to unrelated features that happen to share a hue.
  static const certificateIntermediate = LinearGradient(
    colors: [Color(0xFF7A1F2B), Color(0xFFA83E4C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const certificateAdvanced = LinearGradient(
    colors: [Color(0xFF9C7A0A), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
