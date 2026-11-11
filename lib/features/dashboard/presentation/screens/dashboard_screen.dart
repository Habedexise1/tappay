import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/screens/two_factor_setup_screen.dart';
import '../../../qr_transfer/presentation/qr_transfer_controller.dart';
import '../../../transactions/domain/transaction_model.dart';
import '../../../transactions/presentation/transaction_controller.dart';
import '../../domain/dashboard_models.dart';
import '../dashboard_controller.dart';
import '../widgets/balance_card.dart';
import '../widgets/beneficiaries_list.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/recent_transactions_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  void _showTopUpSheet(BuildContext context) {
    final amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Top Up Balance',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Instant deposit into your TapPay wallet (updates Home Widget automatically)',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Deposit Amount (\$)',
                hintText: '500.00',
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.attach_money_rounded),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Confirm Deposit',
                onPressed: () async {
                  final amount = double.tryParse(amountController.text.trim()) ?? 250.0;
                  final dashboard = context.read<DashboardController>();
                  await dashboard.creditBalance(amount, sender: 'Bank Card Deposit');
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully added \$${amount.toStringAsFixed(2)} to balance!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickTransferSheet(BuildContext context, {Beneficiary? preselected}) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final recipientName = preselected?.name ?? 'Sarah Jenkins';
    final recipientHandle = preselected?.handle ?? '@sarahj';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Send Money',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'To: $recipientName ($recipientHandle)',
                style: const TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Amount (\$)',
                hintText: '50.00',
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.attach_money_rounded),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Note (Optional)',
                hintText: 'Lunch, split bill, etc.',
                controller: noteController,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Authenticate & Send',
                onPressed: () async {
                  final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                  if (amount <= 0) return;

                  final qrController = context.read<QrTransferController>();
                  qrController.setRecipient(
                    name: recipientName,
                    handle: recipientHandle,
                  );

                  Navigator.of(ctx).pop();

                  final tx = await qrController.executeTransfer(
                    amount: amount,
                    note: noteController.text.trim(),
                  );

                  if (tx != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment of \$${amount.toStringAsFixed(2)} confirmed!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTransactionDetails(BuildContext context, TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: tx.isOutflow
                      ? Colors.orange.withValues(alpha: 0.15)
                      : AppColors.primaryGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tx.isOutflow ? Icons.arrow_outward_rounded : Icons.arrow_downward_rounded,
                  color: tx.isOutflow ? Colors.orange : AppColors.primaryGreen,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${tx.isOutflow ? '-' : '+'} ${CurrencyFormatter.format(tx.amount)}',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tx.title,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(ctx, 'Status', tx.status.label),
              _buildDetailRow(ctx, 'Reference', tx.referenceNumber),
              _buildDetailRow(ctx, 'Category', tx.category),
              _buildDetailRow(ctx, 'Recipient', tx.recipientName),
              const SizedBox(height: 24),
              AppButton(
                text: 'Share Receipt',
                variant: AppButtonVariant.secondary,
                icon: Icons.share_rounded,
                onPressed: () {
                  context.read<TransactionController>().shareReceipt(tx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen, width: 1.5),
              ),
              child: const Text(
                'A',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Alex 👋',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                Text(
                  'Financial Hub',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '2FA & Security',
            icon: Icon(Icons.shield_outlined, color: textPrimary, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TwoFactorSetupScreen()),
              );
            },
          ),
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: textPrimary,
              size: 22,
            ),
            onPressed: () => themeController.toggleTheme(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 540,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const BalanceCard(),
                const SizedBox(height: 24),
                QuickActionsBar(
                  onSendPressed: () => _showQuickTransferSheet(context),
                  onReceivePressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Receive QR generated for @alexpay')),
                    );
                  },
                  onScanPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR Scanner deep link: tappay://qr_scanner')),
                    );
                  },
                  onTopUpPressed: () => _showTopUpSheet(context),
                ),
                const SizedBox(height: 28),
                BeneficiariesList(
                  onBeneficiarySelected: (b) => _showQuickTransferSheet(context, preselected: b),
                  onAddBeneficiary: () => _showQuickTransferSheet(context),
                ),
                const SizedBox(height: 24),
                RecentTransactionsList(
                  onTransactionSelected: (tx) => _showTransactionDetails(context, tx),
                  onSeeAllPressed: () {},
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentNavIndex = idx;
          });
        },
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryGreen),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card_rounded, color: AppColors.primaryGreen),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded, color: AppColors.primaryGreen),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryGreen),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
