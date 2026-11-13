import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import '../../../../app/theme/app_colors.dart';

class OtpInputRow extends StatelessWidget {
  final int length;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  const OtpInputRow({
    super.key,
    this.length = 6,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final boxFill = isDark ? const Color(0xFF14241C) : const Color(0xFFF3F6F9);
    final boxBorder = isDark
        ? const Color(0xFF3E5248)
        : const Color(0xFFE5EAF0);

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 54,
      textStyle: TextStyle(
        fontFamily: 'Gordita',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      decoration: BoxDecoration(
        color: boxFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: boxBorder, width: 1.2),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primaryGreen, width: 1.5),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primaryGreen, width: 1.2),
      ),
    );

    return Center(
      child: Pinput(
        length: length,
        controller: controller,
        autofocus: autofocus,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        separatorBuilder: (_) => const SizedBox(width: 8),
        preFilledWidget: Text(
          '-',
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textPrimary.withValues(alpha: 0.35),
          ),
        ),
        onChanged: onChanged,
        onCompleted: onCompleted,
      ),
    );
  }
}
