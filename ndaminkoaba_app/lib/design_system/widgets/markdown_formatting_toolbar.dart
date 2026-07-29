import 'package:flutter/material.dart';

import '../buttons/bouncy_icon_button.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../shadows/app_shadows.dart';
import '../spacing/app_spacing.dart';

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
