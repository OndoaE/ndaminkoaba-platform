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
}
