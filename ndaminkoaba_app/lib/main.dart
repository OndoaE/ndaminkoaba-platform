import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/language/learning_language_provider.dart';
import 'core/locale/locale_provider.dart';
import 'core/network/connectivity_provider.dart';
import 'core/services/storage_service.dart';
import 'core/services/sync_queue_service.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // On web, the browser's own right-click/selection context menu is enabled
  // by default and takes priority over Flutter's — which silently swallows
  // every custom `contextMenuBuilder` (e.g. the markdown formatting toolbar)
  // until this is called. No-op on non-web platforms.
  if (kIsWeb) {
    await BrowserContextMenu.disableContextMenu();
  }

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
          currentLearningLanguageProvider.overrideWith(
            (ref) => savedLearningLanguageId,
          ),
      ],
      child: const NdaMinkoabaApp(),
    ),
  );
}

class NdaMinkoabaApp extends ConsumerStatefulWidget {
  const NdaMinkoabaApp({super.key});

  @override
  ConsumerState<NdaMinkoabaApp> createState() => _NdaMinkoabaAppState();
}

class _NdaMinkoabaAppState extends ConsumerState<NdaMinkoabaApp>
    with WidgetsBindingObserver {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = listenForConnectivityChanges(ref);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A "connected" signal from connectivity_plus can lie (captive portal,
    // real backhaul down) — resume is a second, independent trigger that
    // catches queued syncs the connectivity listener alone would miss.
    if (state == AppLifecycleState.resumed) {
      SyncQueueService().replayAll();
    }
  }

  @override
  Widget build(BuildContext context) {
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
