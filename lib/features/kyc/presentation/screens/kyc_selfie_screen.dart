import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/result_state_screen.dart';
import '../kyc_controller.dart';

class KycSelfieScreen extends StatelessWidget {
  const KycSelfieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kycController = context.watch<KycController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final isCaptured = kycController.isSelfieCaptured;
    final isSubmitting = kycController.submissionState is Loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KYC Verification (3/3)',
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Text(
                  'Selfie Verification',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isCaptured
                      ? 'Selfie captured cleanly! Submit your profile for verification.'
                      : 'Center your face inside the oval frame in a well-lit area.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: 240,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 280,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(140),
                          border: Border.all(
                            color: isCaptured
                                ? AppColors.primaryGreen
                                : AppColors.primaryYellow,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            isCaptured
                                ? Icons.check_circle_rounded
                                : Icons.face_retouching_natural_rounded,
                            size: 84,
                            color: isCaptured
                                ? AppColors.primaryGreen
                                : textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                AppButton(
                  text: isCaptured ? 'Retake Selfie' : 'Take a Selfie',
                  variant: isCaptured
                      ? AppButtonVariant.outline
                      : AppButtonVariant.primary,
                  icon: Icons.camera_alt_rounded,
                  onPressed: isSubmitting ? null : kycController.captureSelfie,
                ),
                if (isCaptured) ...[
                  const SizedBox(height: 14),
                  AppButton(
                    text: 'Submit Verification',
                    isLoading: isSubmitting,
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final ok = await kycController.submitVerification();
                            if (!context.mounted) return;
                            final navigator = Navigator.of(context);
                            if (ok) {
                              navigator.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => ResultStateScreen(
                                    isSuccess: true,
                                    title: 'KYC Verified',
                                    subtitle:
                                        'Your identity and income details have been approved.',
                                    primaryButtonText: 'Back to Dashboard',
                                    onPrimaryPressed: () {
                                      navigator.popUntil(
                                        (route) => route.isFirst,
                                      );
                                    },
                                  ),
                                ),
                                (route) => route.isFirst,
                              );
                            }
                          },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
