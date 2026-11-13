import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/widgets/onboarding_step_header.dart';
import 'image_verification_capture_screen.dart';

class ImageVerificationIntroScreen extends StatelessWidget {
  const ImageVerificationIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const OnboardingStepHeader(),
                        const SizedBox(height: 8),
                        Text(
                          'Image verification',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Take a well-lit selfie, ensuring your face is\nclear and unobstructed, and maintain a\nneutral expression.',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 13,
                            color: textSecondary,
                            height: 1.45,
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: Container(
                            width: 170,
                            height: 290,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1311),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF284236)
                                    : const Color(0xFF1F2937),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 44,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryGreen,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.face_rounded,
                                    size: 48,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Container(
                                  width: 78,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(30),
                                      bottom: Radius.circular(14),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    size: 42,
                                    color: Color(0xFF081711),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        AppButton(
                          text: 'Take a selfie',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ImageVerificationCaptureScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
