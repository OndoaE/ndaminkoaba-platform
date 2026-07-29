import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors/app_colors.dart';

/// Every style is bound to Poppins explicitly here (rather than relying on
/// the ambient `Theme`'s `textTheme` to supply it) so headings render in the
/// brand font even inside widgets that don't inherit the app's text theme —
/// e.g. `Text(..., style: AppTypography.h2)` nested under a plain `Container`.
class AppTypography {
  AppTypography._();

  static final display = GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final h1 = GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final h2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final title = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final body = GoogleFonts.poppins(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static final caption = GoogleFonts.poppins(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  /// Reading typeface for lesson content prose — Andika (SIL International's
  /// literacy-focused typeface) rather than the Poppins used everywhere
  /// else, chosen specifically for its clarity with the extended Latin
  /// characters and diacritics used in African-language orthographies like
  /// Ewondo's. Paired with [lessonBodyStrong] for markdown-authored Ewondo
  /// words within the text.
  static final lessonBody = GoogleFonts.andika(
    fontSize: 17,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  /// Same family/size as [lessonBody], bolded and tinted brand-green — the
  /// style markdown's `**word**` emphasis renders as, so an Ewondo word
  /// stands out as unmistakably bold *and* on-brand, not just heavier black
  /// text.
  static final lessonBodyStrong = GoogleFonts.andika(
    fontSize: 17,
    height: 1.6,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  /// Tabular-figure numerals for anything digits line up against — the
  /// daily-minutes ring's "6/10", pronunciation accuracy percentages, badge
  /// progress counts — so the digits don't jitter in width as they change.
  static final numeric = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
