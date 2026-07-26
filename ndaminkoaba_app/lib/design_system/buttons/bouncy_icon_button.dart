import 'package:flutter/material.dart';

/// A drop-in replacement for [IconButton] that shrinks slightly on
/// press-down and springs back on release, instead of relying only on the
/// platform's flat ripple — the small bit of physicality is what makes an
/// icon read as "tappable" rather than just decorative. Anywhere in the app
/// that hands an [Icon] to a plain [IconButton] can swap to this with no
/// other changes.
class BouncyIconButton extends StatefulWidget {
  const BouncyIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 24,
    this.color,
    this.tooltip,
    this.padding = const EdgeInsets.all(8),
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final double iconSize;
  final Color? color;
  final String? tooltip;
  final EdgeInsetsGeometry padding;

  @override
  State<BouncyIconButton> createState() => _BouncyIconButtonState();
}

class _BouncyIconButtonState extends State<BouncyIconButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.82 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Padding(
          padding: widget.padding,
          child: IconTheme.merge(
            data: IconThemeData(size: widget.iconSize, color: widget.color),
            child: widget.icon,
          ),
        ),
      ),
    );

    if (widget.tooltip == null) return button;
    return Tooltip(message: widget.tooltip!, child: button);
  }
}
