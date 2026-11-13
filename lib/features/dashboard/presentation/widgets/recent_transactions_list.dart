import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/view_state.dart';
import '../../../transactions/domain/transaction_model.dart';
import '../../../transactions/presentation/transaction_controller.dart';

class RecentTransactionsList extends StatelessWidget {
  final ValueChanged<TransactionModel> onTransactionSelected;
  final VoidCallback onSeeAllPressed;

  const RecentTransactionsList({
    super.key,
    required this.onTransactionSelected,
    required this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;
    final txController = context.watch<TransactionController>();

    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            TextButton(
              onPressed: onSeeAllPressed,
              child: Text(
                'See All',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        switch (txController.transactionsState) {
          Loading() => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          ),
          Failure(:final message) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Gordita',
                color: AppColors.accentRed,
                fontSize: 13,
              ),
            ),
          ),
          Empty() => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'No transactions found',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  color: textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Success(:final data) => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length > 5 ? 5 : data.length,
            separatorBuilder: (context, index) => Divider(
              height: 16,
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorderSubtle,
            ),
            itemBuilder: (context, index) {
              final tx = data[index];
              final isOutflow = tx.isOutflow;

              return InkWell(
                onTap: () => onTransactionSelected(tx),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isOutflow
                              ? Icons.arrow_outward_rounded
                              : Icons.arrow_downward_rounded,
                          color: isOutflow
                              ? textPrimary
                              : AppColors.primaryGreen,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Gordita',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormatter.formatRelative(tx.date),
                              style: TextStyle(
                                fontFamily: 'Gordita',
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isOutflow ? '-' : '+'} ${CurrencyFormatter.format(tx.amount)}',
                            style: TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isOutflow
                                  ? textPrimary
                                  : AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tx.category,
                            style: TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Initial() => const SizedBox.shrink(),
        },
      ],
    );
  }
}
