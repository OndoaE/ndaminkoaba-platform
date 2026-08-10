import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_queue_service.dart';

/// Whether the device currently reports a network connection. Seeded with an
/// optimistic `true` (matches every screen's existing online-first
/// assumption) and kept live by [listenForConnectivityChanges] wired near
/// app root — the raw signal only reflects "connected to a network," not
/// "the backend is actually reachable" (see [isConnectivityFailure] in
/// `api_error.dart` for the request-failure side of that distinction).
final connectivityProvider = StateProvider<bool>((ref) => true);

bool _isOnline(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);

/// Starts a background listener that keeps [connectivityProvider] in sync
/// with the OS-reported connectivity state, and replays the offline sync
/// queue whenever connectivity comes back — a "connected" signal can lie
/// (captive portal, backhaul down), so this is a best-effort trigger; app
/// resume (see `main.dart`) is the other, catching what this alone misses.
/// Call once near app root, from a widget's own `ref` (not a separately
/// constructed `ProviderContainer` — `ProviderScope` already owns one, and
/// reading through a second container would silently create disconnected
/// provider state).
StreamSubscription<List<ConnectivityResult>> listenForConnectivityChanges(
  WidgetRef ref,
) {
  var wasOnline = true;

  Connectivity().checkConnectivity().then((results) {
    wasOnline = _isOnline(results);
    ref.read(connectivityProvider.notifier).state = wasOnline;
  });

  return Connectivity().onConnectivityChanged.listen((results) {
    final isOnline = _isOnline(results);
    ref.read(connectivityProvider.notifier).state = isOnline;
    if (isOnline && !wasOnline) {
      SyncQueueService().replayAll();
    }
    wasOnline = isOnline;
  });
}
