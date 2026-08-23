import 'clipboard_paste_result.dart';

/// Non-web fallback — the Syllabus Management screen is admin/desktop-web
/// only in practice (see `AdminShell`'s wide-screen-only gate), so this
/// path realistically never runs, but every platform still needs something
/// to compile against.
Future<ClipboardPasteResult?> readClipboardPasteImpl() async => null;
