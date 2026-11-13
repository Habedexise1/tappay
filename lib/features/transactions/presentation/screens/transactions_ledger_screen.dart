import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/transaction_model.dart';
import '../transaction_controller.dart';
import 'receipt_screen.dart';

class TransactionsLedgerScreen extends StatelessWidget {
  const TransactionsLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TransactionController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final transactions = controller.filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 560,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.filterCategories.map((category) {
                    final selected = controller.selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.lightTextPrimary
                                : textPrimary,
                          ),
                        ),
                        selected: selected,
                        selectedColor: AppColors.primaryGreen,
                        onSelected: (_) => controller.selectCategory(category),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions in this category yet',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: transactions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          final isInflow = tx.type == TransactionType.inflow;
                          return AppCard(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReceiptScreen(transaction: tx),
                                ),
                              );
                            },
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        (isInflow
                                                ? AppColors.primaryGreen
                                                : AppColors.accentRed)
                                            .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    isInflow
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: isInflow
                                        ? AppColors.primaryGreen
                                        : AppColors.accentRed,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.recipientName,
                                        style: TextStyle(
                                          fontFamily: 'Gordita',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${tx.category} • ${DateFormatter.formatRelative(tx.date)}',
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
                                      '${isInflow ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                                      style: TextStyle(
                                        fontFamily: 'Gordita',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isInflow
                                            ? AppColors.primaryGreen
                                            : textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      tx.status.label,
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
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
