import 'package:flutter/material.dart';

import '../buttons/bouncy_icon_button.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../shadows/app_shadows.dart';
import '../spacing/app_spacing.dart';

/// A drop-in [TextEditingController] replacement for markdown content
/// fields that auto-continues `- ` and `1. ` list markers onto the next
/// line when the user presses Enter mid-list — matching the behavior of
/// Word/Notion/GitHub's markdown editor — and removes the marker (exiting
/// the list) when Enter is pressed on an already-empty list item.
///
/// Implemented by overriding the [value] setter rather than listening via
/// [addListener], since that's the one place that sees both the pre-edit
/// value (via the inherited getter) and the incoming edit in the same call,
/// with no separate "previous text" field to keep in sync by hand.
class SmartListTextEditingController extends TextEditingController {
  SmartListTextEditingController({super.text});

  static final _bulletPattern = RegExp(r'^(\s*)-\s+(.*)$');
  static final _numberPattern = RegExp(r'^(\s*)(\d+)\.\s+(.*)$');

  @override
  set value(TextEditingValue newValue) {
    super.value = _continueList(value, newValue);
  }

  TextEditingValue _continueList(TextEditingValue oldValue, TextEditingValue newValue) {
    final oldText = oldValue.text;
    final newText = newValue.text;
    final selection = newValue.selection;

    // Only handle a single plain Enter keystroke: one extra char, a '\n',
    // landing exactly at the (collapsed) cursor. Anything else — typing a
    // normal character, pasting, deleting, programmatic edits from the
    // formatting toolbar — passes through untouched.
    if (!selection.isCollapsed) return newValue;
    final cursor = selection.baseOffset;
    if (cursor <= 0 || cursor > newText.length) return newValue;
    if (newText.length != oldText.length + 1) return newValue;
    if (newText[cursor - 1] != '\n') return newValue;
    final reconstructedOld = newText.substring(0, cursor - 1) + newText.substring(cursor);
    if (reconstructedOld != oldText) return newValue;

    final priorLineStart = cursor - 1 == 0 ? 0 : (newText.lastIndexOf('\n', cursor - 2) + 1);
    final priorLine = newText.substring(priorLineStart, cursor - 1);

    final bulletMatch = _bulletPattern.firstMatch(priorLine);
    if (bulletMatch != null) {
      final rest = bulletMatch.group(2)!;
      if (rest.trim().isEmpty) return _exitList(newText, priorLineStart, cursor);
      final marker = '${bulletMatch.group(1)}- ';
      return _insertMarker(newText, cursor, marker);
    }

    final numberMatch = _numberPattern.firstMatch(priorLine);
    if (numberMatch != null) {
      final rest = numberMatch.group(3)!;
      if (rest.trim().isEmpty) return _exitList(newText, priorLineStart, cursor);
      final next = (int.tryParse(numberMatch.group(2)!) ?? 0) + 1;
      final marker = '${numberMatch.group(1)}$next. ';
      return _insertMarker(newText, cursor, marker);
    }

    return newValue;
  }

  TextEditingValue _exitList(String text, int lineStart, int cursor) {
    final newText = text.substring(0, lineStart) + text.substring(cursor);
    return TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: lineStart));
  }

  TextEditingValue _insertMarker(String text, int cursor, String marker) {
    final newText = text.substring(0, cursor) + marker + text.substring(cursor);
    return TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: cursor + marker.length));
  }
}

/// Applies (or removes) a `- ` / `1. ` marker to every line spanned by
/// [controller]'s current selection, or just the current line when nothing
/// is selected. Numbered lists number sequentially from 1 within the
/// affected block. Used by the Bullet/Numbered list toolbar buttons to
/// start a new list — [SmartListTextEditingController] takes over from
/// there to continue it as the admin keeps typing.
void applyMarkdownListPrefix(TextEditingController controller, {required bool numbered}) {
  final text = controller.text;
  final selection = controller.selection;
  final start = selection.isValid ? selection.start : text.length;
  final end = selection.isValid ? selection.end : text.length;

  final lineStart = start == 0 ? 0 : (text.lastIndexOf('\n', start - 1) + 1);
  final lineEndSearch = text.indexOf('\n', end);
  final lineEnd = lineEndSearch == -1 ? text.length : lineEndSearch;

  final block = text.substring(lineStart, lineEnd);
  var counter = 1;
  final newLines = block.split('\n').map((line) {
    if (numbered) {
      if (RegExp(r'^\d+\.\s').hasMatch(line)) return line;
      return '${counter++}. $line';
    }
    if (line.startsWith('- ')) return line;
    return '- $line';
  }).toList();
  final newBlock = newLines.join('\n');
  final delta = newBlock.length - block.length;

  controller.value = TextEditingValue(
    text: text.replaceRange(lineStart, lineEnd, newBlock),
    selection: TextSelection.collapsed(offset: end + delta),
  );
}

/// Wraps [controller]'s current selection in [prefix]/[suffix] (defaulting
/// [suffix] to [prefix] for symmetric markers like `**`), or inserts both at
/// the cursor when nothing is selected. Leaves the wrapped text selected
/// afterward so stacking formatting (e.g. bold, then italic on the same
/// words) reads naturally rather than losing the selection each time.
void _wrapSelection(TextEditingController controller, String prefix, [String? suffix]) {
  suffix ??= prefix;
  final selection = controller.selection;
  final text = controller.text;
  final start = selection.isValid ? selection.start : text.length;
  final end = selection.isValid ? selection.end : text.length;

  final selected = text.substring(start, end);
  final newText = text.replaceRange(start, end, '$prefix$selected$suffix');
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection(
      baseOffset: start + prefix.length,
      extentOffset: start + prefix.length + selected.length,
    ),
  );
}

Future<void> _insertLink(BuildContext context, TextEditingController controller) async {
  final selection = controller.selection;
  final text = controller.text;
  final start = selection.isValid ? selection.start : text.length;
  final end = selection.isValid ? selection.end : text.length;
  final selectedText = text.substring(start, end);

  final urlController = TextEditingController();
  final url = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Insert Link'),
      content: TextField(
        controller: urlController,
        autofocus: true,
        keyboardType: TextInputType.url,
        decoration: const InputDecoration(labelText: 'URL', hintText: 'https://...'),
        onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, urlController.text.trim()),
          child: const Text('Insert'),
        ),
      ],
    ),
  );
  urlController.dispose();
  if (url == null || url.isEmpty) return;

  final linkText = selectedText.isEmpty ? 'link text' : selectedText;
  final markdownLink = '[$linkText]($url)';
  final newText = text.replaceRange(start, end, markdownLink);
  final linkTextStart = start + 1; // past the opening '['
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection(
      baseOffset: linkTextStart,
      extentOffset: linkTextStart + linkText.length,
    ),
  );
}

class _ToolbarButtonSpec {
  const _ToolbarButtonSpec({required this.icon, required this.tooltip, required this.onPressed});
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
}

/// Builds a [TextField.contextMenuBuilder] that replaces the platform's
/// default copy/paste/select-all menu with a floating Bold / Italic /
/// Underline / Superscript / Link markdown-formatting toolbar, positioned
/// above the current selection via Flutter's own [TextSelectionToolbar]
/// anchoring — no manual Overlay/CompositedTransformFollower plumbing
/// needed. Bold/Italic/Link are native Markdown; Underline/Superscript rely
/// on the custom `<u>`/`<sup>` syntax + builders registered in
/// `nda_markdown_extensions.dart`, which every [MarkdownBody] rendering this
/// controller's saved text must also be given for the formatting to
/// actually display to learners.
Widget Function(BuildContext, EditableTextState) markdownFormattingContextMenuBuilder(
  TextEditingController controller,
) {
  return (BuildContext context, EditableTextState editableTextState) {
    void applyAndClose(VoidCallback apply) {
      apply();
      editableTextState.hideToolbar();
    }

    final buttons = <_ToolbarButtonSpec>[
      _ToolbarButtonSpec(
        icon: Icons.format_bold,
        tooltip: 'Bold',
        onPressed: () => applyAndClose(() => _wrapSelection(controller, '**')),
      ),
      _ToolbarButtonSpec(
        icon: Icons.format_italic,
        tooltip: 'Italic',
        onPressed: () => applyAndClose(() => _wrapSelection(controller, '*')),
      ),
      _ToolbarButtonSpec(
        icon: Icons.format_underlined,
        tooltip: 'Underline',
        onPressed: () => applyAndClose(() => _wrapSelection(controller, '<u>', '</u>')),
      ),
      _ToolbarButtonSpec(
        icon: Icons.superscript,
        tooltip: 'Superscript',
        onPressed: () => applyAndClose(() => _wrapSelection(controller, '<sup>', '</sup>')),
      ),
      _ToolbarButtonSpec(
        icon: Icons.format_list_bulleted,
        tooltip: 'Bullet list',
        onPressed: () => applyAndClose(() => applyMarkdownListPrefix(controller, numbered: false)),
      ),
      _ToolbarButtonSpec(
        icon: Icons.format_list_numbered,
        tooltip: 'Numbered list',
        onPressed: () => applyAndClose(() => applyMarkdownListPrefix(controller, numbered: true)),
      ),
      _ToolbarButtonSpec(
        icon: Icons.link,
        tooltip: 'Link',
        onPressed: () {
          editableTextState.hideToolbar();
          _insertLink(context, controller);
        },
      ),
    ];

    final anchors = editableTextState.contextMenuAnchors;

    return TextSelectionToolbar(
      anchorAbove: anchors.primaryAnchor,
      anchorBelow: anchors.secondaryAnchor ?? anchors.primaryAnchor,
      toolbarBuilder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.circle,
          boxShadow: AppShadows.floating,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
          child: child,
        ),
      ),
      children: [
        for (final button in buttons)
          BouncyIconButton(
            icon: Icon(button.icon),
            iconSize: 18,
            color: AppColors.textPrimary,
            tooltip: button.tooltip,
            onPressed: button.onPressed,
          ),
      ],
    );
  };
}
