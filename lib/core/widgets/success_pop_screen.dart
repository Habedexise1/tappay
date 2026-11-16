import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../../app/config/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../utils/responsive_utils.dart';
import 'settings_page_scaffold.dart';

class SuccessPopScreen extends StatefulWidget {
  final String pageTitle;
  final String title;
  final String message;
  final VoidCallback onDone;
  final Duration autoCloseAfter;

  const SuccessPopScreen({
    super.key,
    required this.pageTitle,
    required this.message,
    required this.onDone,
    this.title = 'Success!',
    this.autoCloseAfter = const Duration(seconds: 2),
  });

  @override
  State<SuccessPopScreen> createState() => _SuccessPopScreenState();
}

class _SuccessPopScreenState extends State<SuccessPopScreen> {
  Timer? _timer;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.autoCloseAfter, _close);
  }

  void _close() {
    if (_closed || !mounted) return;
    _closed = true;
    _timer?.cancel();
    widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final titleColor = isDark ? AppColors.darkTextPrimary : Colors.black;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            SettingsPageScaffold(
              title: widget.pageTitle,
              onBack: _close,
              body: const SizedBox.shrink(),
            ),
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.7),
              ).animate().fadeIn(duration: 200.ms),
            ),
            SafeArea(
              child: ResponsiveContainer(
                maxWidth: 480,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 280),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 40,
                          ),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Semantics(
                                label: 'Success',
                                image: true,
                                child: Lottie.asset(
                                  AppAssets.lottieSuccess,
                                  width: 96,
                                  height: 96,
                                  repeat: false,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 86,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 13,
                                  height: 1.55,
                                  color: AppColors.slate400,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 220.ms)
                        .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
