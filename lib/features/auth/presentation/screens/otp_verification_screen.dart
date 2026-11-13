import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../auth_controller.dart';
import 'change_pin_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String destination;

  const OtpVerificationScreen({
    super.key,
    this.destination = '+1 (555) •••-8921',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().startOtpTimer();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyCode(String code) async {
    if (code.length != 6) return;

    final authController = context.read<AuthController>();
    final success = await authController.verifyOtp(code);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verification successful! You can now reset your PIN.',
            ),
            backgroundColor: AppColors.primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChangePinScreen()),
        );
      } else {
        _pinController.clear();
        _focusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;
    final authController = context.watch<AuthController>();

    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final timerText =
        '0:${authController.otpCountdown.toString().padLeft(2, '0')}';

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: TextStyle(
        fontFamily: 'Gordita',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorderSubtle,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primaryGreen, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primaryGreen, width: 1.2),
      ),
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 440,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Verify with OTP',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit verification code sent to ${widget.destination}',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),

              Center(
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  separatorBuilder: (_) => const SizedBox(width: 8),
                  onCompleted: _verifyCode,
                ),
              ),

              if (authController.otpState is Failure) ...[
                const SizedBox(height: 16),
                Text(
                  (authController.otpState as Failure).message,
                  style: const TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentRed,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    Text(
                      authController.canResendOtp
                          ? 'Didn’t receive any code?'
                          : 'Resend code in $timerText',
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: authController.canResendOtp
                          ? () => authController.resendOtp()
                          : null,
                      child: Text(
                        'Resend OTP Code',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: authController.canResendOtp
                              ? AppColors.primaryGreen
                              : textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              AppButton(
                text: 'Verify & Proceed',
                isLoading: authController.otpState is Loading,
                onPressed: _pinController.text.length == 6
                    ? () => _verifyCode(_pinController.text)
                    : null,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
