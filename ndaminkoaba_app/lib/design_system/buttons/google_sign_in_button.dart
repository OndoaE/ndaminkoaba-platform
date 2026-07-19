import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../config/app_config.dart';
import '../../features/auth/data/auth_service.dart';
import 'google_web_button_stub.dart'
    if (dart.library.js_interop) 'google_web_button_web.dart';
import 'oauth_button.dart';

/// Cross-platform "Continue with Google" button.
///
/// `google_sign_in`'s programmatic `authenticate()` throws
/// `UnimplementedError` on Flutter Web by design — Google requires an
/// interactive flow they control there. This app tried Google's own
/// `renderButton()` via `google_sign_in_web` first, but that package's
/// `FlexHtmlElementView` throws a TypeError under this project's dart2js
/// release build (its MutationObserver/ResizeObserver auto-sizing, not
/// anything in this app). `google_web_button_web.dart` renders the same
/// real Google button through a much simpler, fixed-size `HtmlElementView`
/// that calls `google_identity_services_web`'s `id.renderButton()` directly,
/// skipping that broken auto-resize code entirely. Every other platform
/// keeps using the app's own [OAuthButton] with the normal `authenticate()`
/// call.
class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onLoadingChanged,
    required this.onIdToken,
    required this.onCancelled,
    required this.onError,
  });

  final bool isLoading;
  final ValueChanged<bool> onLoadingChanged;

  /// Exchanges the Google ID token for our own session — same shape on every
  /// platform, so the screen's save-session/navigate logic stays unified.
  final Future<void> Function(String idToken) onIdToken;
  final VoidCallback onCancelled;
  final void Function(Object error) onError;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;
  bool _webReady = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && AppConfig.googleSignInConfigured) {
      _subscription = GoogleSignIn.instance.authenticationEvents.listen(
        _handleWebEvent,
        onError: _handleWebStreamError,
      );
      AuthService.ensureGoogleInitialized()
          .then((_) {
            if (mounted) setState(() => _webReady = true);
          })
          .catchError((Object e, StackTrace stack) {
            debugPrint('[GoogleSignInButton] ensureGoogleInitialized failed: $e\n$stack');
            if (mounted) widget.onError(e);
          });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _handleWebEvent(GoogleSignInAuthenticationEvent event) async {
    if (event is! GoogleSignInAuthenticationEventSignIn) return;

    final idToken = event.user.authentication.idToken;
    if (idToken == null) {
      widget.onError(Exception('Google did not return an ID token.'));
      return;
    }

    widget.onLoadingChanged(true);
    try {
      await widget.onIdToken(idToken);
    } finally {
      if (mounted) widget.onLoadingChanged(false);
    }
  }

  void _handleWebStreamError(Object error, StackTrace stack) {
    debugPrint('[GoogleSignInButton] authenticationEvents stream error: $error\n$stack');
    widget.onLoadingChanged(false);
    if (error is GoogleSignInException &&
        error.code == GoogleSignInExceptionCode.canceled) {
      widget.onCancelled();
    } else {
      widget.onError(error);
    }
  }

  Future<void> _handleNativePress() async {
    widget.onLoadingChanged(true);
    try {
      await AuthService.ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        widget.onError(Exception('Google did not return an ID token.'));
        return;
      }
      await widget.onIdToken(idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        widget.onCancelled();
      } else {
        widget.onError(e);
      }
    } catch (e) {
      widget.onError(e);
    } finally {
      if (mounted) widget.onLoadingChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.googleSignInConfigured) {
      return OAuthButton(
        provider: OAuthProvider.google,
        onPressed: () => widget.onError(OAuthNotConfiguredException('Google')),
      );
    }

    if (!kIsWeb) {
      return OAuthButton(
        provider: OAuthProvider.google,
        isLoading: widget.isLoading,
        onPressed: _handleNativePress,
      );
    }

    if (!_webReady || widget.isLoading) {
      return OAuthButton(
        provider: OAuthProvider.google,
        isLoading: true,
        onPressed: null,
      );
    }

    return SizedBox(height: 44, child: renderGoogleWebButton());
  }
}
