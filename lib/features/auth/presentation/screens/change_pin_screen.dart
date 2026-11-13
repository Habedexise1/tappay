import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_num_pad.dart';
import '../auth_controller.dart';

enum ChangePinStep {
  current(
    'Enter Current PIN',
    'Verify your identity with your existing 4-digit PIN',
  ),
  newPin(
    'Create New PIN',
    'Enter a 4-digit PIN that is easy to remember but hard to guess',
  ),
  confirm('Confirm New PIN', 'Re-enter your new 4-digit PIN to confirm');

  final String title;
  final String subtitle;
  const ChangePinStep(this.title, this.subtitle);
}

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  ChangePinStep _currentStep = ChangePinStep.current;
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  String? _errorMessage;

  String get _activePin => switch (_currentStep) {
    ChangePinStep.current => _currentPin,
    ChangePinStep.newPin => _newPin,
    ChangePinStep.confirm => _confirmPin,
  };

  void _onDigitPressed(String digit) {
    if (_activePin.length < 4) {
      setState(() {
        _errorMessage = null;
        switch (_currentStep) {
          case ChangePinStep.current:
            _currentPin += digit;
            if (_currentPin.length == 4) _handleCurrentPinComplete();
            break;
          case ChangePinStep.newPin:
            _newPin += digit;
            if (_newPin.length == 4) _handleNewPinComplete();
            break;
          case ChangePinStep.confirm:
            _confirmPin += digit;
            if (_confirmPin.length == 4) _handleConfirmPinComplete();
            break;
        }
      });
    }
  }

  void _onDeletePressed() {
    if (_activePin.isNotEmpty) {
      setState(() {
        _errorMessage = null;
        switch (_currentStep) {
          case ChangePinStep.current:
            _currentPin = _currentPin.substring(0, _currentPin.length - 1);
            break;
          case ChangePinStep.newPin:
            _newPin = _newPin.substring(0, _newPin.length - 1);
            break;
          case ChangePinStep.confirm:
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
            break;
        }
      });
    }
  }

  Future<void> _handleCurrentPinComplete() async {
    final authController = context.read<AuthController>();
    final valid = await authController.verifyPin(_currentPin);

    if (mounted) {
      if (valid) {
        setState(() {
          _currentStep = ChangePinStep.newPin;
        });
      } else {
        setState(() {
          _errorMessage = 'Incorrect current PIN. Please try again.';
          _currentPin = '';
        });
      }
    }
  }

  void _handleNewPinComplete() {
    setState(() {
      _currentStep = ChangePinStep.confirm;
    });
  }

  Future<void> _handleConfirmPinComplete() async {
    if (_confirmPin != _newPin) {
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
        _confirmPin = '';
      });
      return;
    }

    final authController = context.read<AuthController>();
    final success = await authController.changePin(
      currentPin: _currentPin,
      newPin: _newPin,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN successfully updated!'),
            backgroundColor: AppColors.primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = authController.pinActionState is Failure
              ? (authController.pinActionState as Failure).message
              : 'Failed to update PIN';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (_currentStep == ChangePinStep.confirm) {
              setState(() {
                _currentStep = ChangePinStep.newPin;
                _confirmPin = '';
              });
            } else if (_currentStep == ChangePinStep.newPin) {
              setState(() {
                _currentStep = ChangePinStep.current;
                _newPin = '';
              });
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 420,
          child: Column(
            children: [
              const SizedBox(height: 16),

              Text(
                _currentStep.title,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _currentStep.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              AppPinIndicator(
                pinLength: _activePin.length,
                maxLength: 4,
                hasError: _errorMessage != null,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentRed,
                  ),
                ),
              ],

              const Spacer(),

              AppNumPad(
                onDigitPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
                showBiometric: false,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
