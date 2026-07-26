import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

class WeekCalendarDay {
  const WeekCalendarDay({required this.date, required this.completed, required this.minutes});

  final DateTime date;
  final bool completed;
  final int minutes;
}

/// M-S row of completion checkmarks for the Practice screen's weekly
/// calendar. Expects exactly 7 days, oldest first (as returned by
/// GET /practice/weekly-calendar).
class WeekCalendar extends StatelessWidget {
  const WeekCalendar({super.key, required this.days});

  final List<WeekCalendarDay> days;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (index) {
        final day = days[index];
        final isToday = index == days.length - 1;

        return Column(
          children: [
            Text(
              index < _dayLabels.length ? _dayLabels[index] : '',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 6),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: day.completed ? AppColors.primary : AppColors.progressRingTrack,
                border: isToday
                    ? Border.all(color: AppColors.secondary, width: 2)
                    : null,
              ),
              child: Icon(
                day.completed ? Icons.check : Icons.circle,
                size: day.completed ? 16 : 6,
                color: day.completed ? Colors.white : AppColors.textSecondary.withValues(alpha: 0.4),
              ),
            ),
          ],
        );
      }),
    );
  }
}
