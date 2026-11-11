import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';
import 'welcome_screen.dart';

/// TapPay Splash Screen with iconic green brand canvas and centered logo.
class SplashScreen extends StatefulWidget {
  final bool enableTimer;
  final bool enableAnimations;

  const SplashScreen({
    super.key,
    this.enableTimer = true,
    this.enableAnimations = true,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    if (widget.enableTimer) {
      _navigationTimer = Timer(const Duration(milliseconds: 2200), () {
        if (mounted) {
          _navigateToWelcome();
        }
      });
    }
  }

  void _navigateToWelcome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WelcomeScreen(enableAnimations: widget.enableAnimations),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget text = const Text(
      'tappay.',
      style: TextStyle(
        fontFamily: 'Gordita',
        fontSize: 52,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        letterSpacing: -1.5,
      ),
    );

    if (widget.enableAnimations) {
      text = text
          .animate()
          .scale(
            begin: const Offset(0.85, 0.85),
            end: const Offset(1.0, 1.0),
            duration: 600.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(duration: 500.ms);
    }

    return Scaffold(
      backgroundColor: AppColors.splashGreen,
      body: InkWell(
        onTap: _navigateToWelcome,
        child: Center(
          child: text,
        ),
      ),
    );
  }
}
