import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../domain/dashboard_models.dart';
import '../dashboard_controller.dart';

class BeneficiariesList extends StatelessWidget {
  final ValueChanged<Beneficiary> onBeneficiarySelected;
  final VoidCallback onAddBeneficiary;

  const BeneficiariesList({
    super.key,
    required this.onBeneficiarySelected,
    required this.onAddBeneficiary,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;
    final dashboard = context.watch<DashboardController>();

    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Send Again',
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            Text(
              'See All',
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: dashboard.beneficiaries.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                // Add New Beneficiary Avatar Button
                return InkWell(
                  onTap: onAddBeneficiary,
                  borderRadius: BorderRadius.circular(30),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorderSubtle,
                            width: 1.5,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: textPrimary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'New',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final beneficiary = dashboard.beneficiaries[index - 1];
              return InkWell(
                onTap: () => onBeneficiarySelected(beneficiary),
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0FDF4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.primaryGreen.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        beneficiary.initials,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF065F46),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        beneficiary.name.split(' ').first,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

