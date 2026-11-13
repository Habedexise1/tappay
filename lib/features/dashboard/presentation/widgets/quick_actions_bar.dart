import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import 'package:provider/provider.dart';

class QuickActionsBar extends StatelessWidget {
  final VoidCallback onSendPressed;
  final VoidCallback onReceivePressed;
  final VoidCallback onScanPressed;
  final VoidCallback onTopUpPressed;

  const QuickActionsBar({
    super.key,
    required this.onSendPressed,
    required this.onReceivePressed,
    required this.onScanPressed,
    required this.onTopUpPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          context: context,
          isDark: isDark,
          title: 'Send',
          icon: Icons.arrow_outward_rounded,
          onTap: onSendPressed,
        ),
        _buildActionItem(
          context: context,
          isDark: isDark,
          title: 'Receive',
          icon: Icons.qr_code_rounded,
          onTap: onReceivePressed,
        ),
        _buildActionItem(
          context: context,
          isDark: isDark,
          title: 'Scan QR',
          icon: Icons.qr_code_scanner_rounded,
          onTap: onScanPressed,
          isHighlighted: true,
        ),
        _buildActionItem(
          context: context,
          isDark: isDark,
          title: 'Top Up',
          icon: Icons.add_rounded,
          onTap: onTopUpPressed,
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required bool isDark,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.primaryGreen
                  : isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(18),
              border: isHighlighted
                  ? null
                  : Border.all(
                      color: isDark ? AppColors.darkBorder : Colors.transparent,
                    ),
            ),
            child: Icon(
              icon,
              size: 26,
              color: isHighlighted
                  ? const Color(0xFF081711)
                  : isDark
                  ? Colors.white
                  : const Color(0xFF0D1311),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
