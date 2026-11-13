import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/widgets/onboarding_step_header.dart';
import '../kyc_controller.dart';

class ImageVerificationThankYouScreen extends StatelessWidget {
  const ImageVerificationThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kycController = context.watch<KycController>();
    final isSubmitting = kycController.submissionState is Loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              const OnboardingStepHeader(),
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.white : const Color(0xFF0D1311),
                    width: 14,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Thank you!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your data is being processed. Our team\nis reviewing your submission to ensure\nsecurity and compliance, and will notify\nyou when it is complete.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Continue',
                isLoading: isSubmitting,
                onPressed: () async {
                  await kycController.submitVerification();
                  if (!context.mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
