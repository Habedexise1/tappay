import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/theme_controller.dart';
import '../utils/responsive_utils.dart';
import 'app_button.dart';
import 'app_card.dart';

class ResultStateScreen extends StatelessWidget {
  final bool isSuccess;
  final String title;
  final String subtitle;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final Map<String, String>? summaryDetails;

  const ResultStateScreen({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.subtitle,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.summaryDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;

    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final statusColor = isSuccess
        ? AppColors.primaryGreen
        : AppColors.accentRed;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 460,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(),

              Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 56,
                      color: statusColor,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),

              if (summaryDetails != null && summaryDetails!.isNotEmpty) ...[
                const SizedBox(height: 28),
                AppCard(
                  child: Column(
                    children: summaryDetails!.entries.map((entry) {
                      final isLast = entry.key == summaryDetails!.keys.last;
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 13,
                                  color: textSecondary,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  entry.value,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!isLast)
                            Divider(
                              height: 20,
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorderSubtle,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],

              const Spacer(),

              AppButton(text: primaryButtonText, onPressed: onPrimaryPressed),

              if (secondaryButtonText != null &&
                  onSecondaryPressed != null) ...[
                const SizedBox(height: 12),
                AppButton(
                  text: secondaryButtonText!,
                  variant: AppButtonVariant.secondary,
                  onPressed: onSecondaryPressed,
                ),
              ],

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
