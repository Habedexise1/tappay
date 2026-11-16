import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_num_pad.dart';
import '../auth_controller.dart';

enum _ChangePinStep {
  current('Enter PIN', 'Input your TapPay 4-digit PIN'),
  newPin('Enter new PIN', 'Input your new 4-digit PIN');

  final String title;
  final String subtitle;
  const _ChangePinStep(this.title, this.subtitle);
}

class ChangePinSheet extends StatefulWidget {
  const ChangePinSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showAppBottomSheet<bool>(
      context: context,
      showDragHandle: false,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      maxWidth: 520,
      expand: true,
      useRootNavigator: true,
      builder: (_) => const ChangePinSheet(),
    );
  }

  @override
  State<ChangePinSheet> createState() => _ChangePinSheetState();
}

class _ChangePinSheetState extends State<ChangePinSheet> {
  static const _pinLength = 4;

  _ChangePinStep _step = _ChangePinStep.current;
  String _currentPin = '';
  String _entered = '';
  String? _error;

  bool get _isComplete => _entered.length == _pinLength;

  void _onDigit(String digit) {
    if (_entered.length >= _pinLength) return;
    setState(() {
      _error = null;
      _entered += digit;
    });
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() {
      _error = null;
      _entered = _entered.substring(0, _entered.length - 1);
    });
  }

  void _onBack() {
    if (_step == _ChangePinStep.newPin) {
      setState(() {
        _step = _ChangePinStep.current;
        _entered = '';
        _error = null;
      });
      return;
    }
    Navigator.of(context).pop(false);
  }

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    switch (_step) {
      case _ChangePinStep.current:
        final ok = await auth.verifyPin(_entered);
        if (!mounted) return;
        if (!ok) return _fail('Incorrect PIN. Try again.');
        setState(() {
          _currentPin = _entered;
          _entered = '';
          _step = _ChangePinStep.newPin;
        });
      case _ChangePinStep.newPin:
        if (_entered == _currentPin) {
          return _fail('New PIN must be different from your current PIN.');
        }
        final ok = await auth.changePin(
          currentPin: _currentPin,
          newPin: _entered,
        );
        if (!mounted) return;
        if (!ok) {
          final state = auth.pinActionState;
          return _fail(
            state is Failure<bool> ? state.message : 'Could not change PIN.',
          );
        }
        Navigator.of(context).pop(true);
    }
  }

  void _fail(String message) {
    HapticFeedback.heavyImpact();
    setState(() {
      _error = message;
      _entered = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : Colors.black;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextPrimary;
    final boxBg = isDark ? AppColors.darkSurface : Colors.white;
    final isBusy = context.watch<AuthController>().pinActionState is Loading;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    key: const ValueKey('change_pin_back_btn'),
                    tooltip: 'Back',
                    icon: Icon(Icons.arrow_back, size: 26, color: textPrimary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: isBusy ? null : _onBack,
                  ),
                ),
                const SizedBox(height: 8),
                Image.asset(AppAssets.shieldPin, width: 64, height: 68),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Column(
                    key: ValueKey(_step),
                    children: [
                      Text(
                        _step.title,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _step.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 15,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    for (var i = 0; i < _pinLength; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: boxBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _error != null
                                    ? AppColors.accentRed
                                    : i == _entered.length
                                    ? AppColors.primaryGreen
                                    : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.slate300),
                                width: 1.2,
                              ),
                            ),
                            child: i < _entered.length
                                ? Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: textPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : Container(
                                    width: 16,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.slate300,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(
                  height: 30,
                  child: _error == null
                      ? null
                      : Center(
                          child: Text(
                            _error!,
                            key: const ValueKey('change_pin_error'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accentRed,
                            ),
                          ),
                        ),
                ),
                const Spacer(),
                AppNumPad(
                  style: AppNumPadStyle.rounded,
                  onDigitPressed: isBusy ? (_) {} : _onDigit,
                  onDeletePressed: isBusy ? () {} : _onDelete,
                ),
                const SizedBox(height: 24),
                AppButton(
                  key: const ValueKey('change_pin_submit_btn'),
                  text: 'Change PIN',
                  isLoading: isBusy,
                  onPressed: _isComplete ? _submit : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
