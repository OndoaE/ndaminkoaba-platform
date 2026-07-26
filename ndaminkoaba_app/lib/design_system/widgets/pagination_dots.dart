import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

/// Dot-indicator row used for paging between sibling lessons in a module,
/// and anywhere else a short linear sequence needs a position indicator.
class PaginationDots extends StatelessWidget {
  const PaginationDots({super.key, required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final selected = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: selected ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
