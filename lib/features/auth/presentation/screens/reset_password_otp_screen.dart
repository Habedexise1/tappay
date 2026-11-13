import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/view_state.dart';
import '../auth_controller.dart';
import '../widgets/onboarding_step_header.dart';
import '../widgets/otp_input_row.dart';
import 'signup/signup_password_screen.dart';

class ResetPasswordOtpScreen extends StatefulWidget {
  final String email;

  const ResetPasswordOtpScreen({super.key, required this.email});

  @override
  State<ResetPasswordOtpScreen> createState() => _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState extends State<ResetPasswordOtpScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().startOtpTimer(seconds: 300);
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _submitOtp(String code) async {
    final ok = await context.read<AuthController>().verifyOtp(code);
    if (ok && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SignUpPasswordScreen(isResetFlow: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
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
    final isVerifying = authController.otpState is Loading;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingStepHeader(),
              const SizedBox(height: 8),
              Text(
                'Reset password',
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
                'Please enter the OTP sent to your email\n${widget.email} below to authenticate',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 32),
              OtpInputRow(onChanged: (_) {}, onCompleted: _submitOtp),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: authController.canResendOtp
                    ? () => authController.resendOtp(seconds: 300)
                    : null,
                child: Text(
                  authController.canResendOtp
                      ? 'Resend code'
                      : 'Send code in ${_formatTimer(authController.otpCountdown)}',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: authController.canResendOtp
                        ? AppColors.primaryGreen
                        : textPrimary,
                  ),
                ),
              ),
              if (isVerifying) ...[
                const SizedBox(height: 24),
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
