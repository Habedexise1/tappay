import 'package:flutter/material.dart';

import '../../../../../app/config/app_assets.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../create_pin_screen.dart';

class CreatingAccountScreen extends StatefulWidget {
  final bool enableAutoRedirect;

  const CreatingAccountScreen({super.key, this.enableAutoRedirect = true});

  @override
  State<CreatingAccountScreen> createState() => _CreatingAccountScreenState();
}

class _CreatingAccountScreenState extends State<CreatingAccountScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (widget.enableAutoRedirect) {
      _progressController.forward().whenComplete(() {
        if (!mounted) return;
        showCreatePinBottomSheet(context);
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 420,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.creatingAccount,
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  'Creating your\naccount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.2,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    final percent = (_progressController.value * 100).round();
                    return Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progressController.value,
                              minHeight: 5,
                              backgroundColor: isDark
                                  ? const Color(0xFF1F382B)
                                  : const Color(0xFFE5EDF2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 38,
                          child: Text(
                            '$percent%',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
