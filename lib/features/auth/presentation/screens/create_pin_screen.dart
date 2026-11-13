import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../auth_controller.dart';
import '../widgets/onboarding_step_header.dart';
import 'setup_biometrics_screen.dart';

Future<void> showCreatePinBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const PopScope(
      canPop: false,
      child: CreatePinScreen(isBottomSheet: true),
    ),
  );
}

class CreatePinScreen extends StatefulWidget {
  final bool isBottomSheet;

  const CreatePinScreen({super.key, this.isBottomSheet = false});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  String? _errorText;

  String get _activePin => _isConfirmStep ? _confirmPin : _firstPin;

  void _onDigitPressed(String digit) {
    if (_activePin.length >= 4) return;
    HapticFeedback.lightImpact();

    setState(() {
      _errorText = null;
      if (_isConfirmStep) {
        _confirmPin += digit;
      } else {
        _firstPin += digit;
      }
    });

    if (!_isConfirmStep && _firstPin.length == 4) {
      _isConfirmStep = true;
      _confirmPin = '';
    } else if (_isConfirmStep && _confirmPin.length == 4) {
      _handleConfirmComplete();
    }
  }

  Future<void> _handleConfirmComplete() async {
    if (_confirmPin != _firstPin) {
      HapticFeedback.heavyImpact();
      setState(() {
        _confirmPin = '';
        _errorText = 'PINs do not match. Try again.';
      });
      return;
    }

    await context.read<AuthController>().saveCreatedPin(_confirmPin);
    if (!mounted) return;

    if (widget.isBottomSheet) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (_) => const SetupBiometricsScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SetupBiometricsScreen()),
      );
    }
  }

  void _onBackspace() {
    if (_activePin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _errorText = null;
      if (_isConfirmStep) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else {
        _firstPin = _firstPin.substring(0, _firstPin.length - 1);
      }
    });
  }

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
    final boxFill = isDark ? const Color(0xFF14241C) : const Color(0xFFF3F6F9);
    final boxBorder = isDark
        ? const Color(0xFF3E5248)
        : const Color(0xFFE5EAF0);

    final content = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: widget.isBottomSheet
                  ? MediaQuery.sizeOf(context).height * 0.88
                  : constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  if (_isConfirmStep)
                    OnboardingStepHeader(
                      onBack: () {
                        setState(() {
                          _isConfirmStep = false;
                          _confirmPin = '';
                          _firstPin = '';
                          _errorText = null;
                        });
                      },
                    )
                  else
                    const SizedBox(height: 36),
                  const SizedBox(height: 8),
                  Image.asset(
                    AppAssets.shieldAlert,
                    width: 54,
                    height: 54,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isConfirmStep ? 'Confirm PIN' : 'Create PIN',
                    textAlign: TextAlign.center,
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
                    'Your account has been created. We\nneed to secure your account against\nfraud or theft',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 13,
                      color: textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final filled = index < _activePin.length;
                      final isActive = index == _activePin.length;
                      return Container(
                        width: 60,
                        height: 54,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: boxFill,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _errorText != null
                                ? AppColors.accentRed
                                : isActive
                                ? AppColors.primaryGreen
                                : boxBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          filled ? '•' : '-',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: filled
                                ? textPrimary
                                : textPrimary.withValues(alpha: 0.45),
                          ),
                        ),
                      );
                    }),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorText!,
                      style: const TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentRed,
                      ),
                    ),
                  ],
                  const Spacer(),
                  _PinGridKeypad(
                    isDark: isDark,
                    onDigitPressed: _onDigitPressed,
                    onBackspacePressed: _onBackspace,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (widget.isBottomSheet) {
      return Container(
        height: MediaQuery.sizeOf(context).height * 0.92,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: ResponsiveContainer(
            maxWidth: 460,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: content,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 460,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: content,
        ),
      ),
    );
  }
}

class _PinGridKeypad extends StatelessWidget {
  final bool isDark;
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;

  const _PinGridKeypad({
    required this.isDark,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    final keyBg = isDark ? const Color(0xFF0E2118) : const Color(0xFFF5F7FA);
    final keyFg = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: row.map((item) {
              if (item.isEmpty) {
                return const Expanded(child: SizedBox(height: 54));
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: item == 'back'
                        ? onBackspacePressed
                        : () => onDigitPressed(item),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: item == 'back' ? Colors.transparent : keyBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: item == 'back'
                          ? Icon(
                              Icons.backspace_outlined,
                              size: 22,
                              color: keyFg,
                            )
                          : Text(
                              item,
                              style: TextStyle(
                                fontFamily: 'Gordita',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: keyFg,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
