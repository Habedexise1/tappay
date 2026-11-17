import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppPrivacyShield extends StatelessWidget {
  final Widget child;
  final ValueListenable<bool> obscured;

  const AppPrivacyShield({
    super.key,
    required this.child,
    required this.obscured,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        Positioned.fill(
          child: ValueListenableBuilder<bool>(
            valueListenable: obscured,
            builder: (context, isObscured, _) =>
                isObscured ? const _ShieldOverlay() : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _ShieldOverlay extends StatelessWidget {
  const _ShieldOverlay();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
      child: Container(
        color: isDark ? const Color(0xE60D0D12) : const Color(0xE6FFFFFF),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF6C2BD9).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 36,
                color: Color(0xFF6C2BD9),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'TapPay Secure Shield',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF111827),
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Financial data is protected',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
