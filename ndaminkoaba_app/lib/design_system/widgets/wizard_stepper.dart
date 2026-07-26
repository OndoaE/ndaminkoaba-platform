import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

/// Numbered step progress bar for the Create/Edit Course wizard — a row of
/// circles connected by a line, the active/completed steps filled in.
class WizardStepper extends StatelessWidget {
  const WizardStepper({super.key, required this.steps, required this.currentStep});

  final List<String> steps;

  /// Zero-indexed.
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= currentStep ? AppColors.primary : Colors.white,
                  border: Border.all(color: i <= currentStep ? AppColors.primary : AppColors.divider, width: 2),
                ),
                alignment: Alignment.center,
                child: i < currentStep
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == currentStep ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                steps[i],
                style: AppTypography.caption.copyWith(
                  fontWeight: i == currentStep ? FontWeight.w700 : FontWeight.w400,
                  color: i == currentStep ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (i != steps.length - 1)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 2,
                color: i < currentStep ? AppColors.primary : AppColors.divider,
              ),
            ),
        ],
      ],
    );
  }
}
