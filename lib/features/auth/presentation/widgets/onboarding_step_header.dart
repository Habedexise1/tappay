import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import 'step_progress_ring.dart';

class OnboardingStepHeader extends StatelessWidget {
  final int? step;
  final int totalSteps;
  final VoidCallback? onBack;

  const OnboardingStepHeader({
    super.key,
    this.step,
    this.totalSteps = 4,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Icon(Icons.arrow_back_rounded, color: iconColor, size: 24),
            ),
          ),
          if (step != null)
            StepProgressRing(step: step!, totalSteps: totalSteps)
          else
            const SizedBox(width: 44, height: 44),
        ],
      ),
    );
  }
}
