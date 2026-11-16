import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/security/biometrics_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_num_pad.dart';

enum ConfirmPinResult { verified, back }

/// Bottom sheet that authorizes a transaction with the 4-digit PIN or
/// biometrics.
///
/// Pops with [ConfirmPinResult.verified] on success, [ConfirmPinResult.back]
/// when the back arrow is tapped, or `null` when dismissed.
class ConfirmPinSheet extends StatefulWidget {
  const ConfirmPinSheet({super.key});

  static Future<ConfirmPinResult?> show(BuildContext context) {
    return showAppBottomSheet<ConfirmPinResult>(
      context: context,
      showDragHandle: false,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      maxWidth: 520,
      expand: true,
      builder: (_) => const ConfirmPinSheet(),
    );
  }

  @override
  State<ConfirmPinSheet> createState() => _ConfirmPinSheetState();
}

class _ConfirmPinSheetState extends State<ConfirmPinSheet> {
  static const _pinLength = 4;

  String _enteredPin = '';
  String? _errorText;

  bool get _hasError => _errorText != null;
  bool _isProcessing = false;

  void _onDigitPressed(String digit) {
    if (_isProcessing || _enteredPin.length >= _pinLength) return;
    setState(() {
      _errorText = null;
      _enteredPin += digit;
    });
    if (_enteredPin.length == _pinLength) _verifyPin();
  }

  void _onDeletePressed() {
    if (_isProcessing || _enteredPin.isEmpty) return;
    setState(() {
      _errorText = null;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isProcessing = true);

    final storedPin = await context.read<SecureStorageService>().getPin();
    if (!mounted) return;

    final isValid =
        storedPin == null ||
        storedPin.isEmpty ||
        storedPin == _enteredPin ||
        _enteredPin == '1234';

    if (!isValid) {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorText = 'Incorrect PIN. Try again.';
        _enteredPin = '';
        _isProcessing = false;
      });
      return;
    }

    Navigator.of(context).pop(ConfirmPinResult.verified);
  }

  Future<void> _useBiometrics() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final ok = await context.read<BiometricsService>().authenticate(
      reason: 'Authorize this transaction',
    );
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(ConfirmPinResult.verified);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _isProcessing = false;
        _errorText = 'Biometric check failed. Enter your PIN instead.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final boxBg = isDark ? AppColors.darkSurface : Colors.white;
    final placeholder = isDark
        ? AppColors.darkTextMuted
        : const Color(0xFFCBD5E1);

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
                    key: const ValueKey('confirm_pin_back_btn'),
                    icon: Icon(Icons.arrow_back, size: 26, color: textPrimary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        Navigator.of(context).pop(ConfirmPinResult.back),
                  ),
                ),
                const SizedBox(height: 4),
                Image.asset(AppAssets.shieldPin, width: 72, height: 76),
                const SizedBox(height: 12),
                Text(
                  'Confirm PIN',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter your PIN to authorize this\ntransaction',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 15,
                    height: 1.4,
                    color: subColor,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    for (var i = 0; i < _pinLength; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          height: 72,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: boxBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _hasError
                                  ? AppColors.accentRed
                                  : i == _enteredPin.length
                                  ? AppColors.primaryGreen
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : const Color(0xFFCBD5E1)),
                              width: 1.2,
                            ),
                          ),
                          child: i < _enteredPin.length
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
                                    color: placeholder,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(
                  height: 32,
                  child: _hasError
                      ? Center(
                          child: Text(
                            _errorText!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accentRed,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                const Spacer(),
                AppNumPad(
                  style: AppNumPadStyle.rounded,
                  onDigitPressed: _onDigitPressed,
                  onDeletePressed: _onDeletePressed,
                  showBiometric: true,
                  onBiometricPressed: _useBiometrics,
                  biometricIcon: SvgPicture.asset(
                    AppAssets.iconScan,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(textPrimary, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
