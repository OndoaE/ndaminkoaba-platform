import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'clipboard_paste_result.dart';

/// Reads the system clipboard via the browser's async Clipboard API
/// (Chrome/Edge; requires a user gesture and, outside localhost, HTTPS —
/// both already true for the "Coller depuis le presse-papiers" button
/// click on the deployed admin site). Tries an image first (a screenshot or
/// copied chart photo), then falls back to plain text (a table
/// copy-pasted from a spreadsheet/document). Returns null on any
/// permission denial, unsupported browser, or empty clipboard — every
/// failure mode here is silent-and-safe, never a crash, since pasting is
/// just one of three ways into this screen (drag-and-drop and "Choisir un
/// fichier" still work).
Future<ClipboardPasteResult?> readClipboardPasteImpl() async {
  try {
    final items = (await web.window.navigator.clipboard.read().toDart).toDart;
    for (final item in items) {
      final types = item.types.toDart.map((t) => t.toDart).toList();
      final imageType = types.firstWhere(
        (t) => t.startsWith('image/'),
        orElse: () => '',
      );
      if (imageType.isNotEmpty) {
        final blob = await item.getType(imageType).toDart;
        final buffer = (await blob.arrayBuffer().toDart).toDart;
        return ClipboardPasteResult.image(buffer.asUint8List(), imageType);
      }
    }
  } catch (_) {
    // Fall through to the text attempt below.
  }

  try {
    final text = (await web.window.navigator.clipboard.readText().toDart).toDart;
    if (text.trim().isNotEmpty) {
      return ClipboardPasteResult.text(text);
    }
  } catch (_) {
    // Nothing readable on the clipboard, or permission denied.
  }

  return null;
}
