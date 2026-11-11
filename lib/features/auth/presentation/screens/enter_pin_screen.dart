import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_num_pad.dart';
import '../auth_controller.dart';
import 'change_pin_screen.dart';
import 'otp_verification_screen.dart';

/// Enter PIN screen with custom animated digit indicators, numpad, and biometric trigger.
class EnterPinScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;

  const EnterPinScreen({
    super.key,
    this.onAuthenticated,
  });

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  String _enteredPin = '';
  bool _hasError = false;

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _hasError = false;
        _enteredPin += digit;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _hasError = false;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    final authController = context.read<AuthController>();
    final success = await authController.verifyPin(_enteredPin);

    if (mounted) {
      if (success) {
        if (widget.onAuthenticated != null) {
          widget.onAuthenticated!();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN Verified successfully!'),
              backgroundColor: AppColors.primaryGreen,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        setState(() {
          _hasError = true;
          _enteredPin = '';
        });
      }
    }
  }

  Future<void> _triggerBiometrics() async {
    final authController = context.read<AuthController>();
    final success = await authController.authenticateWithBiometrics(
      reason: 'Scan biometrics to unlock TapPay',
    );

    if (mounted && success) {
      if (widget.onAuthenticated != null) {
        widget.onAuthenticated!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric verification successful!'),
            backgroundColor: AppColors.primaryGreen,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;
    final authController = context.watch<AuthController>();

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: textPrimary,
              size: 20,
            ),
            onPressed: () => themeController.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 420,
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Title & Subtitle
              Text(
                'Enter your PIN',
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
                'Enter your 4-digit security code to proceed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // PIN Indicator Dots
              AppPinIndicator(
                pinLength: _enteredPin.length,
                maxLength: 4,
                hasError: _hasError,
              ),

              // Error feedback
              if (_hasError) ...[
                const SizedBox(height: 12),
                Text(
                  authController.pinActionState is Failure
                      ? (authController.pinActionState as Failure).message
                      : 'Incorrect PIN. Please try again.',
                  style: const TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentRed,
                  ),
                ),
              ],

              const Spacer(),

              // Custom Numpad
              AppNumPad(
                onDigitPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
                showBiometric: authController.settings.isBiometricsEnabled,
                onBiometricPressed: _triggerBiometrics,
              ),

              const SizedBox(height: 16),

              // Bottom Links: Forgot PIN & Change PIN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OtpVerificationScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot PIN?',
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.primaryGreen : const Color(0xFF0D1311),
                      ),
                    ),
                  ),
                  Text(
                    '•',
                    style: TextStyle(color: textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChangePinScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Change PIN',
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.primaryGreen : const Color(0xFF0D1311),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
