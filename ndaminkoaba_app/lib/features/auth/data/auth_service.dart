import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../config/app_config.dart';
import '../domain/models/login_response.dart';
import '../../../core/network/api_client.dart';

/// Thrown when a learner taps an OAuth button before you've finished the
/// Google Cloud / Facebook Developer setup described in the README.
class OAuthNotConfiguredException implements Exception {
  OAuthNotConfiguredException(this.provider);
  final String provider;
}

/// Thrown when the learner backs out of the native Google/Facebook picker —
/// this is a normal outcome, not an error, and callers should just return to
/// the form silently instead of showing a snackbar.
class OAuthCancelledException implements Exception {}

class AuthService {
  // `GoogleSignIn.instance` is a process-wide singleton, but each screen
  // (login/register) constructs its own `AuthService()` — an instance-level
  // guard here would let `initialize()` get called twice across screens,
  // which the plugin documents as "undefined behavior". Static keeps the
  // guard correct regardless of how many AuthService instances exist.
  static bool _googleInitialized = false;
  bool _facebookWebInitialized = false;

  /// `google_sign_in`'s `initialize()` takes two different-purpose IDs, and
  /// each platform plugin only honors one of them:
  /// - Web's plugin *requires* `clientId` and asserts `serverClientId` is
  ///   null ("serverClientId is not supported on Web").
  /// - Android's plugin ignores `clientId` outright ("The clientId parameter
  ///   is not supported on Android") and requires `serverClientId` — without
  ///   it, Android silently never returns an ID token.
  /// - iOS accepts both; `clientId` is optional there (falls back to the
  ///   value baked into `GoogleService-Info.plist`), but `serverClientId` is
  ///   still what makes the returned ID token's audience match our backend's
  ///   `GOOGLE_CLIENT_ID` allow-list.
  /// Passing the Web Client ID as `serverClientId` everywhere except Web
  /// itself satisfies all three at once.
  static Future<void> ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? AppConfig.googleWebClientId : null,
      serverClientId: kIsWeb ? null : AppConfig.googleWebClientId,
    );
    _googleInitialized = true;
  }

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.dio.post(
      '/auth/login',
      data: {"email": email, "password": password},
    );

    return LoginResponse.fromJson(response.data);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await ApiClient.dio.post(
      '/auth/register',
      data: {"fullName": fullName, "email": email, "password": password},
    );
  }

  /// Native path only (Android/iOS/desktop). `google_sign_in`'s
  /// `authenticate()` throws `UnimplementedError` on Flutter Web by design —
  /// Google requires their own rendered button there, which is why web uses
  /// `GoogleSignInButton` (design_system/buttons) instead of this method.
  Future<LoginResponse> loginWithGoogle() async {
    if (!AppConfig.googleSignInConfigured) {
      throw OAuthNotConfiguredException('Google');
    }

    await ensureGoogleInitialized();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw OAuthCancelledException();
      }
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw OAuthNotConfiguredException('Google');
    }

    return exchangeGoogleIdToken(idToken);
  }

  /// Shared tail end of Google sign-in: trades a Google ID token (obtained
  /// either from the native `authenticate()` flow above, or from the web
  /// button's `authenticationEvents` stream) for our own session.
  Future<LoginResponse> exchangeGoogleIdToken(String idToken) async {
    final response = await ApiClient.dio.post(
      '/auth/google',
      data: {"idToken": idToken},
    );

    return LoginResponse.fromJson(response.data);
  }

  Future<LoginResponse> loginWithFacebook() async {
    // Only Web/desktop need an explicit JS SDK init call with the App ID;
    // Android/iOS read their own copy from AndroidManifest.xml/Info.plist.
    if (kIsWeb) {
      if (!AppConfig.facebookWebSignInConfigured) {
        throw OAuthNotConfiguredException('Facebook');
      }
      if (!_facebookWebInitialized) {
        await FacebookAuth.instance.webAndDesktopInitialize(
          appId: AppConfig.facebookAppId,
          cookie: true,
          xfbml: true,
          version: "v19.0",
        );
        _facebookWebInitialized = true;
      }
    }

    final result = await FacebookAuth.instance.login(
      // The backend verifies the token against the Graph API, which needs a
      // classic access token — the default `limited` tracking only returns
      // an OIDC-style token the Graph API `/me` endpoint can't use.
      loginTracking: LoginTracking.enabled,
    );

    if (result.status == LoginStatus.cancelled) {
      throw OAuthCancelledException();
    }

    final accessToken = result.accessToken;
    if (result.status != LoginStatus.success || accessToken == null) {
      throw OAuthNotConfiguredException('Facebook');
    }

    final response = await ApiClient.dio.post(
      '/auth/facebook',
      data: {"accessToken": accessToken.tokenString},
    );

    return LoginResponse.fromJson(response.data);
  }
}
