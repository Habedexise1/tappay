import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../auth_controller.dart';
import '../widgets/onboarding_step_header.dart';
import 'reset_password_otp_screen.dart';
import 'signup/signup_contact_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      setState(() => _errorText = 'Please enter a valid email address');
      return;
    }

    final ok = await context.read<AuthController>().requestPasswordReset(email);
    if (!ok || !mounted) return;

    await _showSentSheet(email);
  }

  Future<void> _showSentSheet(String email) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBg = isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground;
        final textPrimary = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        final textSecondary = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : const Color(0xFFF3F6F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 36,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sent',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your password reset OTP has been sent\n$email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 12,
                  color: textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              AppButton(
                text: 'Enter OTP',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResetPasswordOtpScreen(email: email),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().authFlowState is Loading;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingStepHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        'Provide your registered email address\nto receive authorization',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 13,
                          color: textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 28),
                      AppTextField(
                        label: 'Email',
                        hintText: 'johndoe@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _errorText,
                        onChanged: (_) {
                          if (_errorText != null) {
                            setState(() => _errorText = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const SignUpContactScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Don’t have an account? Sign Up',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(text: 'Next', isLoading: isLoading, onPressed: _onNext),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
