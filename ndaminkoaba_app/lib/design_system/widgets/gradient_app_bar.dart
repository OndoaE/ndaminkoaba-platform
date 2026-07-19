import 'package:flutter/material.dart';

/// A premium gradient app bar used consistently across the Administrator
/// screens. Behaves like a normal [AppBar] (works as `Scaffold.appBar`) but
/// paints a diagonal two-tone gradient instead of a flat color.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    super.key,
    required this.title,
    this.colors = const [Color(0xFF0B5D3B), Color(0xFF0D7A4C)],
    this.actions,
    this.bottom,
    this.leading,
    this.titleWidget,
  });

  final String title;
  final List<Color> colors;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;

  /// Overrides the default `Text(title)` when a richer title (e.g. a badge
  /// image next to the text) is needed. [title] is still required for the
  /// widget's semantics/accessibility label.
  final Widget? titleWidget;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: titleWidget ?? Text(title),
      centerTitle: false,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: actions,
      bottom: bottom,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
