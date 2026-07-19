import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';

/// The app's active locale. Seeded from [StorageService.getLanguageCode] via
/// an override in `main()` before `runApp`, so the first frame already
/// renders in the right language — no flash of the wrong locale.
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

/// Persists the choice and updates the provider together, so callers (the
/// language-selection screen) never have to remember to do both.
Future<void> setAppLocale(WidgetRef ref, Locale locale) async {
  await StorageService.saveLanguageCode(locale.languageCode);
  ref.read(localeProvider.notifier).state = locale;
}
