import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

class DonutSegment {
  const DonutSegment({required this.label, required this.percent, required this.color});

  final String label;
  final int percent;
  final Color color;
}

/// Multi-legend donut for the admin dashboards' "Course Completion"/"Content
/// Quality" cards — a ring built from [fl_chart]'s PieChart (already a
/// project dependency) with the overall % centered inside, and a legend row
/// per segment below.
class SegmentedDonut extends StatelessWidget {
  const SegmentedDonut({
    super.key,
    required this.overallPercent,
    required this.segments,
    this.size = 120,
  });

  final int overallPercent;
  final List<DonutSegment> segments;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: [
                    for (final segment in segments)
                      PieChartSectionData(
                        value: segment.percent.toDouble().clamp(0.01, double.infinity),
                        color: segment.color,
                        showTitle: false,
                        radius: size * 0.18,
                      ),
                  ],
                  centerSpaceRadius: size * 0.32,
                  sectionsSpace: 2,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$overallPercent%', style: AppTypography.numeric.copyWith(fontSize: size * 0.2)),
                  Text(AppLocalizations.of(context).adminOverallLabel, style: AppTypography.caption.copyWith(fontSize: size * 0.09)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final segment in segments)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: segment.color, shape: BoxShape.circle)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(segment.label, style: AppTypography.caption, overflow: TextOverflow.ellipsis)),
                      Text('${segment.percent}%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
