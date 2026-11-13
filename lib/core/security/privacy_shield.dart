import 'dart:ui';
import 'package:flutter/material.dart';

class AppPrivacyShield extends StatefulWidget {
  final Widget child;
  final bool isShieldEnabled;

  const AppPrivacyShield({
    super.key,
    required this.child,
    this.isShieldEnabled = true,
  });

  @override
  State<AppPrivacyShield> createState() => _AppPrivacyShieldState();
}

class _AppPrivacyShieldState extends State<AppPrivacyShield>
    with WidgetsBindingObserver {
  bool _isBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isShieldEnabled) return;

    final shouldObscure =
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden;

    if (shouldObscure != _isBackgrounded) {
      setState(() {
        _isBackgrounded = shouldObscure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (_isBackgrounded)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xE60D0D12)
                    : const Color(0xE6FFFFFF),
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF111827),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Financial data is protected',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
