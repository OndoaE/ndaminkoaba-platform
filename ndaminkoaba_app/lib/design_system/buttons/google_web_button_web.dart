import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:google_identity_services_web/id.dart' as gis;
import 'package:web/web.dart' as web;

const _viewType = 'nda_google_signin_button';
bool _viewFactoryRegistered = false;

/// Google's own rendered "Continue with Google" button — the only way to
/// start an *interactive* sign-in on Flutter Web (`authenticate()` throws
/// `UnimplementedError` there by design; see [GoogleSignInButton]'s doc
/// comment). Deliberately bypasses `google_sign_in_web`'s own `renderButton`
/// / `FlexHtmlElementView` — that wrapper's MutationObserver/ResizeObserver
/// auto-sizing throws a TypeError under this project's dart2js release
/// build. This calls `google_identity_services_web`'s lower-level
/// `id.renderButton()` directly against a plain, fixed-size
/// `HtmlElementView`, skipping the auto-resize machinery entirely.
Widget renderGoogleWebButton() {
  if (!_viewFactoryRegistered) {
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final element = web.document.createElement('div');
      element.setAttribute(
        'style',
        'width: 100%; height: 100%; overflow: hidden; display: flex; '
            'align-items: center; justify-content: center;',
      );
      return element;
    });
    _viewFactoryRegistered = true;
  }

  return HtmlElementView(
    viewType: _viewType,
    onPlatformViewCreated: (int viewId) {
      final element = ui_web.platformViewRegistry.getViewById(viewId);
      gis.id.renderButton(
        element,
        gis.GsiButtonConfiguration(
          shape: gis.ButtonShape.pill,
          size: gis.ButtonSize.large,
          theme: gis.ButtonTheme.outline,
          text: gis.ButtonText.continue_with,
        ),
      );
    },
  );
}
