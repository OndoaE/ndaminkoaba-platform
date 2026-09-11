import 'package:flutter/material.dart';

/// Caps a single-column screen's content at a readable width and centres
/// it, so it degrades to full-width on a phone (where [maxWidth] is never
/// reached) but stops stretching edge-to-edge on a wide desktop-web
/// window — where an uncapped column produces multi-hundred-character
/// line lengths and comically oversized cards.
///
/// Deliberately NOT applied inside [LearnerShell] itself, because several
/// screens (the lessons hub, the book library, the book reader) use the
/// extra width on purpose for a genuine two-pane list+detail or
/// side-by-side layout — wrapping every shell child here would squash
/// those. Instead each single-column screen wraps its own top-level
/// scrollable content in this widget.
class PageWidth extends StatelessWidget {
  const PageWidth({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
