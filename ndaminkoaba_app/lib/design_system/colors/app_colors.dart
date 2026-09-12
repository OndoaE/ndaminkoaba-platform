import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Heritage green family — primary brand color plus two deeper shades for
  // gradients/pressed states (e.g. the sidebar, hero cards).
  static const primary = Color(0xFF0B5D46);
  static const darkGreen = Color(0xFF073F35);
  static const veryDarkGreen = Color(0xFF061A17);

  // Heritage gold — active states, premium/selected emphasis. Never the
  // app's general CTA color (that's `primary`).
  static const secondary = Color(0xFFD6A51D);
  static const lightGold = Color(0xFFF0C63C);

  static const background = Color(0xFFF8F4EA);
  static const lightCream = Color(0xFFFFFDF8);
  static const surface = Colors.white;

  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFD32F2F);

  static const textPrimary = Color(0xFF171A18);
  static const textSecondary = Color(0xFF757975);

  static const divider = Color(0xFFE8E1D3);

  static const ai = Color(0xFF4A6CF7);

  /// A deep maroon reminiscent of leather-bound Bibles — the Bible
  /// feature's accent color, used for its hero banner, cards, and CTAs.
  static const scripture = Color(0xFF8B3A3A);

  // Fabric-inspired secondary accents (from the Ewondo textile's teal and
  // blue threads) — used sparingly for variety, never as a primary CTA
  // color. `floralRed` is distinct from `scripture`: this is a general
  // heritage accent, `scripture` stays specific to the Bible feature.
  static const floralRed = Color(0xFFC62828);
  static const teal = Color(0xFF168C83);
  static const mutedBlue = Color(0xFF237C95);

  // Learner relaunch tokens — streaks, progress rings, badges, and the
  // decorative wave shapes on the new cream/gold Home dashboard.
  static const streakFlame = Color(0xFFFF6B35);
  static const progressRingTrack = Color(0xFFEFE7D3);
  static const cardAlt = Color(0xFFF3ECD9);
  static const badgeLocked = Color(0xFFD8D0BC);
  static const badgeEarned = Color(0xFFD6A51D);
}