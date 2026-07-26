import 'dart:math';

import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

/// Bar-style waveform, shared by Nnanga voice-message bubbles and the
/// pronunciation-practice recorder. Two modes:
/// - `amplitudes` supplied → static bars sized from that normalized (0-1)
///   data, for a recorded/playback message.
/// - `amplitudes` null and `animate: true` → a looping pulse animation, for
///   an in-progress recording where no amplitude data exists yet.
class WaveformVisualizer extends StatefulWidget {
  const WaveformVisualizer({
    super.key,
    this.amplitudes,
    this.animate = false,
    this.barCount = 24,
    this.height = 32,
    this.color,
  });

  final List<double>? amplitudes;
  final bool animate;
  final int barCount;
  final double height;
  final Color? color;

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<double> _randomSeeds;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final random = Random();
    _randomSeeds = List.generate(widget.barCount, (_) => random.nextDouble());
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    if (widget.amplitudes != null) {
      return _bars(
        widget.amplitudes!.length >= widget.barCount
            ? widget.amplitudes!.sublist(0, widget.barCount)
            : [...widget.amplitudes!, ...List.filled(widget.barCount - widget.amplitudes!.length, 0.1)],
        color,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.value;
        final values = List.generate(widget.barCount, (i) {
          if (!widget.animate) return 0.15;
          final wave = (sin((phase * 2 * pi) + (_randomSeeds[i] * 2 * pi)) + 1) / 2;
          return 0.2 + wave * 0.8;
        });
        return _bars(values, color);
      },
    );
  }

  Widget _bars(List<double> values, Color color) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(values.length, (i) {
          final v = values[i].clamp(0.08, 1.0);
          return Container(
            width: 3,
            height: widget.height * v,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
