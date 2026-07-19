class AppConfig {
  AppConfig._();

  /// Overridable via `--dart-define=API_BASE_URL=...` at build time — e.g.
  /// a LAN IP for an Android APK installed on a physical device, since
  /// `127.0.0.1` on that device refers to the phone itself, not this
  /// machine running the backend.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: "http://127.0.0.1:3000/api",
  );

  /// Backend origin without the `/api` prefix, used to resolve relative
  /// asset URLs returned by the API (e.g. certificate PDFs under `/uploads`).
  static String get origin => baseUrl.replaceAll(RegExp(r'/api/?$'), '');

  static String resolveUrl(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return pathOrUrl;
    }
    return '$origin$pathOrUrl';
  }

  static const appName = "NdaMinkoaba";

  /// Web/Android/iOS OAuth Client ID from Google Cloud Console. Only the Web
  /// one is required here — `google_sign_in` reads the Android/iOS ones from
  /// `google-services.json`/`GoogleService-Info.plist` automatically. Empty
  /// until you finish the Google Cloud Console setup (see README).
  static const googleWebClientId =
      "1069029230986-btkpgu7smsf7c74k4mp7pp7prgju3mo7.apps.googleusercontent.com";

  /// Whether Google sign-in has been configured yet. `OAuthButton` uses this
  /// to show a "not configured yet" message instead of calling an
  /// uninitialized SDK.
  static bool get googleSignInConfigured => googleWebClientId.isNotEmpty;

  /// Facebook App ID, only needed on Web/desktop where
  /// `flutter_facebook_auth` must be initialized with it explicitly before
  /// first use (`AuthService.loginWithFacebook`). Android/iOS read their own
  /// copy from AndroidManifest.xml/Info.plist instead. Empty until you've
  /// created a Facebook App (see README).
  static const facebookAppId = "";

  static bool get facebookWebSignInConfigured => facebookAppId.isNotEmpty;
}
