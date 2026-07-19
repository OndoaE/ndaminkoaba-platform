import 'package:flutter/widgets.dart';

/// Non-web fallback — never actually called, since [GoogleSignInButton] only
/// reaches for this on `kIsWeb`. Exists so the conditional import always has
/// a target (Android/iOS can't compile the `dart:js_interop` web code in
/// `google_web_button_web.dart`).
Widget renderGoogleWebButton() => const SizedBox.shrink();
