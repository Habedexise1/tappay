import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';

class AppPinIndicator extends StatelessWidget {
  final int pinLength;
  final int maxLength;
  final bool hasError;

  const AppPinIndicator({
    super.key,
    required this.pinLength,
    this.maxLength = 4,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (index) {
        final isFilled = index < pinLength;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
                ? AppColors.accentRed
                : isFilled
                ? AppColors.primary
                : isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightBorder,
            border: Border.all(
              color: hasError
                  ? AppColors.accentRed
                  : isFilled
                  ? AppColors.primary
                  : isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
              width: 2,
            ),
            boxShadow: isFilled && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}

enum AppNumPadStyle { circle, rounded }

class AppNumPad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;
  final AppNumPadStyle style;

  /// Custom widget for the biometric key (e.g. a face-scan SVG).
  final Widget? biometricIcon;

  const AppNumPad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
    this.showBiometric = false,
    this.style = AppNumPadStyle.circle,
    this.biometricIcon,
  });

  Widget _buildKey(BuildContext context, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (style == AppNumPadStyle.rounded) {
      return _RoundedKey(
        semanticsLabel: value,
        onTap: () {
          HapticFeedback.lightImpact();
          onDigitPressed(value);
        },
        child: Text(
          value,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onDigitPressed(value);
        },
        customBorder: const CircleBorder(),
        splashColor: AppColors.primary.withValues(alpha: 0.15),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                : AppColors.lightSurface,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 28,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildRounded(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    Widget row(List<Widget> keys) => Row(
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: keys[i]),
        ],
      ],
    );

    final hasBiometric = showBiometric && onBiometricPressed != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row(['1', '2', '3'].map((d) => _buildKey(context, d)).toList()),
        const SizedBox(height: 12),
        row(['4', '5', '6'].map((d) => _buildKey(context, d)).toList()),
        const SizedBox(height: 12),
        row(['7', '8', '9'].map((d) => _buildKey(context, d)).toList()),
        const SizedBox(height: 12),
        row([
          if (hasBiometric)
            _RoundedKey(
              key: const ValueKey('numpad_biometric_key'),
              semanticsLabel: 'Use biometrics',
              highlighted: true,
              onTap: () {
                HapticFeedback.mediumImpact();
                onBiometricPressed!();
              },
              child: biometricIcon ??
                  Icon(Icons.fingerprint_rounded, size: 26, color: iconColor),
            )
          else
            const SizedBox(height: 58),
          _buildKey(context, '0'),
          _RoundedKey(
            key: const ValueKey('numpad_delete_key'),
            semanticsLabel: 'Delete',
            onTap: () {
              HapticFeedback.mediumImpact();
              onDeletePressed();
            },
            child: Icon(Icons.backspace_outlined, size: 22, color: iconColor),
          ),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (style == AppNumPadStyle.rounded) return _buildRounded(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map((d) => _buildKey(context, d)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map((d) => _buildKey(context, d)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map((d) => _buildKey(context, d)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (showBiometric && onBiometricPressed != null)
              _buildActionKey(
                context: context,
                icon: Icons.fingerprint_rounded,
                onTap: onBiometricPressed!,
              )
            else
              const SizedBox(width: 72, height: 72),
            _buildKey(context, '0'),
            _buildActionKey(
              context: context,
              icon: Icons.backspace_outlined,
              onTap: onDeletePressed,
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundedKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool highlighted;
  final String semanticsLabel;

  const _RoundedKey({
    super.key,
    required this.child,
    required this.onTap,
    required this.semanticsLabel,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = highlighted
        ? (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9))
        : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F1F1));

    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primary.withValues(alpha: 0.15),
          child: SizedBox(height: 58, child: Center(child: child)),
        ),
      ),
    );
  }
}
