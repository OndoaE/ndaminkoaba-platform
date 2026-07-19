import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/language/learning_language_provider.dart';
import 'core/locale/locale_provider.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read the saved language before the first frame so there's no flash of
  // the wrong locale — a fresh install (no saved value) stays on the
  // provider's English default until the language-selection screen sets one.
  final savedLanguageCode = await StorageService.getLanguageCode();
  final savedLearningLanguageId = await StorageService.getLearningLanguageId();

  runApp(
    ProviderScope(
      overrides: [
        if (savedLanguageCode != null)
          localeProvider.overrideWith((ref) => Locale(savedLanguageCode)),
        if (savedLearningLanguageId != null)
          currentLearningLanguageProvider.overrideWith((ref) => savedLearningLanguageId),
      ],
      child: const NdaMinkoabaApp(),
    ),
  );
}

class NdaMinkoabaApp extends ConsumerWidget {
  const NdaMinkoabaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'NdaMinkoaba',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
