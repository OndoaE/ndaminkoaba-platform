import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

/// Markdown's core/GitHub-flavored syntax has no underline or superscript,
/// and flutter_markdown's default inline-HTML handling leaves raw tags as
/// literal text rather than turning them into elements — so `<u>`/`<sup>`
/// only work here because these two syntaxes exist to explicitly match and
/// elementize them. [ndaMarkdownInlineSyntaxes] is additive (flutter_markdown
/// merges custom syntaxes with its default GitHub-flavored set), so bold,
/// italic, links etc. keep working unchanged alongside these.
class _UnderlineSyntax extends md.InlineSyntax {
  _UnderlineSyntax() : super(r'<u>(.+?)</u>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element('u', [md.Text(match[1]!)]));
    return true;
  }
}

class _SuperscriptSyntax extends md.InlineSyntax {
  _SuperscriptSyntax() : super(r'<sup>(.+?)</sup>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element('sup', [md.Text(match[1]!)]));
    return true;
  }
}

/// Pass to every [MarkdownBody]/[Markdown] that should support the toolbar's
/// Underline/Superscript buttons, alongside [ndaMarkdownBuilders].
final List<md.InlineSyntax> ndaMarkdownInlineSyntaxes = [
  _UnderlineSyntax(),
  _SuperscriptSyntax(),
];

class _UnderlineBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return Text(
      element.textContent,
      style: (parentStyle ?? preferredStyle ?? const TextStyle())
          .copyWith(decoration: TextDecoration.underline),
    );
  }
}

class _SuperscriptBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final base = parentStyle ?? preferredStyle ?? const TextStyle();
    return Transform.translate(
      offset: const Offset(0, -4),
      child: Text(
        element.textContent,
        style: base.copyWith(fontSize: (base.fontSize ?? 14) * 0.7),
      ),
    );
  }
}

/// Pass to every [MarkdownBody]/[Markdown] alongside [ndaMarkdownInlineSyntaxes].
final Map<String, MarkdownElementBuilder> ndaMarkdownBuilders = {
  'u': _UnderlineBuilder(),
  'sup': _SuperscriptBuilder(),
};

/// Shared `onTapLink` for every content [MarkdownBody] — without this, `[text](url)`
/// links parse and render but silently do nothing when tapped.
void ndaMarkdownOnTapLink(String text, String? href, String title) {
  if (href == null) return;
  final uri = Uri.tryParse(href);
  if (uri == null) return;
  launchUrl(uri, mode: LaunchMode.externalApplication);
}
