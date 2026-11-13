import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 52,
  });

  ({Color bgColor, Color fgColor, Border? border}) _resolveStyle({
    required bool isDark,
    required bool isEnabled,
  }) {
    final disabledAlpha = isEnabled ? 1.0 : 0.5;

    return switch (variant) {
      AppButtonVariant.primary => (
        bgColor: AppColors.primaryGreen.withValues(alpha: disabledAlpha),
        fgColor: AppColors.lightTextPrimary.withValues(alpha: disabledAlpha),
        border: null,
      ),
      AppButtonVariant.secondary => (
        bgColor:
            (isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant)
                .withValues(alpha: disabledAlpha),
        fgColor:
            (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                .withValues(alpha: disabledAlpha),
        border: isDark
            ? Border.all(color: AppColors.darkBorder, width: 1)
            : null,
      ),
      AppButtonVariant.outline => (
        bgColor: isDark
            ? AppColors.cardWhite.withValues(alpha: disabledAlpha)
            : Colors.transparent,
        fgColor: AppColors.lightTextPrimary.withValues(alpha: disabledAlpha),
        border: isDark
            ? null
            : Border.all(
                color: AppColors.lightBorder.withValues(alpha: disabledAlpha),
                width: 1.5,
              ),
      ),
      AppButtonVariant.text => (
        bgColor: Colors.transparent,
        fgColor: AppColors.primaryGreen.withValues(alpha: disabledAlpha),
        border: null,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;
    final style = _resolveStyle(isDark: isDark, isEnabled: isEnabled);

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: text,
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: width ?? double.infinity,
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: style.bgColor,
            borderRadius: BorderRadius.circular(height / 2),
            border: style.border,
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(style.fgColor),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: style.fgColor),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: style.fgColor,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
