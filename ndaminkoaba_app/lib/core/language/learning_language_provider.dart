import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';

/// The Cameroonian language the learner is currently studying (e.g. Ewondo,
/// Bassa) — an account preference, distinct from the app's UI locale
/// (`localeProvider`, English/French). Seeded from
/// [StorageService.getLearningLanguageId] via an override in `main()` before
/// `runApp`. Null means no language has been chosen yet — callers route to
/// the language-selection screen in that case.
final currentLearningLanguageProvider = StateProvider<String?>((ref) => null);

/// Persists the choice and updates the provider together, so callers (the
/// language-selection screen, the Profile "switch language" row) never have
/// to remember to do both.
Future<void> setLearningLanguage(WidgetRef ref, String languageId) async {
  await StorageService.saveLearningLanguageId(languageId);
  ref.read(currentLearningLanguageProvider.notifier).state = languageId;
}
