import 'clipboard_paste_reader_stub.dart'
    if (dart.library.html) 'clipboard_paste_reader_web.dart';
import 'clipboard_paste_result.dart';

export 'clipboard_paste_result.dart';

/// Reads an image or text off the system clipboard — see the web
/// implementation for the real behavior and its browser-support caveats.
Future<ClipboardPasteResult?> readClipboardPaste() => readClipboardPasteImpl();
