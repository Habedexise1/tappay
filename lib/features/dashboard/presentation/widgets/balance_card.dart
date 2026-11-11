import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../dashboard_controller.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;
    final dashboard = context.watch<DashboardController>();

    final displayBalance = dashboard.isBalanceMasked
        ? CurrencyFormatter.mask()
        : CurrencyFormatter.format(dashboard.balance);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFF0D1311),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Account Label + Eye Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Primary Balance',
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFA1B3AA),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  dashboard.isBalanceMasked
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: dashboard.isBalanceMasked ? 'Reveal Balance' : 'Hide Balance',
                onPressed: () async {
                  final allowed = await dashboard.toggleBalanceMask();
                  if (!allowed && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Authentication required to reveal balance'),
                        backgroundColor: AppColors.accentRed,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Main Balance Display
          Text(
            displayBalance,
            style: const TextStyle(
              fontFamily: 'Gordita',
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.0,
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Tag & Inflow Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: '@alexpay'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account handle @alexpay copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '@alexpay',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.copy_rounded, color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, color: AppColors.primaryGreen, size: 12),
                    SizedBox(width: 4),
                    Text(
                      '+12.8% this month',
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

