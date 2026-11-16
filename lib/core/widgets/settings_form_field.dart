import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import 'settings_page_scaffold.dart';

class SettingsFormField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final bool filled;
  final bool obscureText;
  final Widget? suffix;
  final String? errorText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  const SettingsFormField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hintText,
    this.filled = false,
    this.obscureText = false,
    this.suffix,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final radius = BorderRadius.circular(8);
    final outline = OutlineInputBorder(
      borderRadius: radius,
      borderSide: filled
          ? BorderSide.none
          : BorderSide(color: palette.fieldBorder, width: 1),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: palette.heading,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          readOnly: filled,
          enableInteractiveSelection: true,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          autofillHints: autofillHints,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 14,
            color: filled ? palette.body : palette.title,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 14,
              color: palette.body,
            ),
            errorText: errorText,
            errorStyle: const TextStyle(
              fontFamily: 'Gordita',
              fontSize: 12,
              color: AppColors.accentRed,
            ),
            filled: true,
            fillColor: filled ? palette.filledField : palette.card,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: suffix,
            border: outline,
            enabledBorder: outline,
            disabledBorder: outline,
            focusedBorder: filled
                ? outline
                : OutlineInputBorder(
                    borderRadius: radius,
                    borderSide: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 1.4,
                    ),
                  ),
            errorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: AppColors.accentRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(
                color: AppColors.accentRed,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordVisibilityToggle extends StatelessWidget {
  final bool obscured;
  final VoidCallback onPressed;

  const PasswordVisibilityToggle({
    super.key,
    required this.obscured,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return IconButton(
      tooltip: obscured ? 'Show password' : 'Hide password',
      onPressed: onPressed,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 22,
        color: palette.icon,
      ),
    );
  }
}
