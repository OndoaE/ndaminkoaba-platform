import 'dart:typed_data';

/// What [readClipboardPaste] found on the system clipboard — either an
/// image (checked first, since a screenshot/photo paste is the more
/// specific signal) or plain text (covers a table copy-pasted from a
/// spreadsheet/document, which browsers deliver as tab/newline-separated
/// text, not a binary format).
class ClipboardPasteResult {
  const ClipboardPasteResult.image(this.imageBytes, this.imageMimeType) : text = null;
  const ClipboardPasteResult.text(this.text)
      : imageBytes = null,
        imageMimeType = null;

  final Uint8List? imageBytes;
  final String? imageMimeType;
  final String? text;

  bool get isImage => imageBytes != null;
}
