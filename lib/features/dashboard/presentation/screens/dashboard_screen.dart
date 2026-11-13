import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/flag_icon.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../auth/presentation/screens/change_pin_screen.dart';
import '../../../auth/presentation/screens/two_factor_setup_screen.dart';
import '../../../kyc/presentation/kyc_controller.dart';
import '../../../kyc/presentation/screens/image_verification_intro_screen.dart';
import '../../../qr_transfer/presentation/screens/qr_generator_screen.dart';
import '../../../qr_transfer/presentation/screens/qr_scanner_screen.dart';
import '../../../transactions/domain/transaction_model.dart';
import '../../../transactions/presentation/screens/receipt_screen.dart';
import '../../../transactions/presentation/screens/transactions_ledger_screen.dart';
import '../../../transactions/presentation/transaction_controller.dart';
import '../../domain/dashboard_models.dart';
import '../dashboard_controller.dart';
import 'send_money_beneficiaries_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;

  void _showSelectCurrencySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final sheetBg = isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground;
        final titleColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        final borderColor = isDark
            ? AppColors.darkBorder
            : AppColors.lightBorder;
        final selectedBg = isDark
            ? AppColors.darkSurfaceVariant
            : const Color(0xFFD9F7EA);
        final itemBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

        final controller = sheetContext.watch<DashboardController>();

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Currency',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 16),
                ...WalletCurrency.values.map((currency) {
                  final isSelected = controller.selectedCurrency == currency;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        controller.selectCurrency(currency);
                        Navigator.of(sheetContext).pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? selectedBg : itemBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : borderColor,
                            width: isSelected ? 1.4 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            FlagIcon(
                              assetPath: currency.flagAsset,
                              fallbackEmoji: currency.flagEmoji,
                              width: 26,
                              height: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                currency.label,
                                style: TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: titleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSendMoneyOptionsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final sheetBg = isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground;
        final titleColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        final subColor = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
        final borderColor = isDark
            ? AppColors.darkBorder
            : AppColors.lightBorder;
        final cardBg = isDark ? AppColors.darkSurface : const Color(0xFFF6F8F7);

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Send Money',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 16),
                _SheetOptionTile(
                  icon: Icons.near_me_outlined,
                  title: 'TapPay',
                  subtitle: 'Send money to a TapPay user',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  titleColor: titleColor,
                  subtitleColor: subColor,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BeneficiariesScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _SheetOptionTile(
                  icon: Icons.near_me_outlined,
                  title: isDark ? 'Other Banks' : 'Send to bank',
                  subtitle: 'Send money to external account',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  titleColor: titleColor,
                  subtitleColor: subColor,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const BeneficiariesScreen(isBankTransfer: true),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoreQuickActionsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final sheetBg = isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground;
        final titleColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        final subColor = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
        final borderColor = isDark
            ? AppColors.darkBorder
            : AppColors.lightBorder;
        final cardBg = isDark ? AppColors.darkSurface : const Color(0xFFF6F8F7);

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 22),
                _SheetOptionTile(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Account details',
                  subtitle: 'View your account informations',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  titleColor: titleColor,
                  subtitleColor: subColor,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showAccountDetailsSheet();
                  },
                ),
                const SizedBox(height: 12),
                _SheetOptionTile(
                  icon: Icons.swap_vert_rounded,
                  title: 'Swap Currencies',
                  subtitle: 'Convert to another currency',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  titleColor: titleColor,
                  subtitleColor: subColor,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showSelectCurrencySheet();
                  },
                ),
                const SizedBox(height: 12),
                _SheetOptionTile(
                  icon: Icons.receipt_long_rounded,
                  title: 'Account Statement',
                  subtitle: 'Generate a statement of your transactions',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  titleColor: titleColor,
                  subtitleColor: subColor,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TransactionsLedgerScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAccountDetailsSheet() {
    final auth = context.read<AuthController>();
    final dashboard = context.read<DashboardController>();
    final firstName = auth.signUpDraft.firstName.trim().isEmpty
        ? 'Jimmy'
        : auth.signUpDraft.firstName.trim();
    final lastName = auth.signUpDraft.lastName.trim();
    final fullName = lastName.isEmpty ? firstName : '$firstName $lastName';
    final tag = auth.signUpDraft.tapTag.trim().isEmpty
        ? '@jimmy'
        : auth.signUpDraft.tapTag.trim();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final sheetBg = isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground;
        final titleColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        final subColor = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
        final borderColor = isDark
            ? AppColors.darkBorder
            : AppColors.lightBorder;

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Account details',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Account Name',
                  value: fullName,
                  labelColor: subColor,
                  valueColor: titleColor,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'TapTag',
                  value: tag,
                  labelColor: subColor,
                  valueColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Account Number',
                  value: '9048271653',
                  labelColor: subColor,
                  valueColor: titleColor,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Active Currency',
                  value: dashboard.selectedCurrency.label,
                  labelColor: subColor,
                  valueColor: titleColor,
                ),
                const SizedBox(height: 22),
                AppButton(
                  text: 'Done',
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFundWalletSheet() {
    final amountController = TextEditingController();
    String? errorText;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final sheetBg = isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground;
            final titleColor = isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary;
            final borderColor = isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder;
            final dashboard = context.read<DashboardController>();
            final currency = dashboard.selectedCurrency;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: borderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isDark ? 'Fund Wallet' : 'Add Money',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Amount (${currency.code})',
                        hintText: '0.00',
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        errorText: errorText,
                        onChanged: (_) => setModalState(() => errorText = null),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        text: isDark ? 'Fund Wallet' : 'Add Money',
                        onPressed: () async {
                          final amount = double.tryParse(
                            amountController.text.trim().replaceAll(',', ''),
                          );
                          if (amount == null || amount <= 0) {
                            setModalState(
                              () => errorText = 'Enter a valid amount',
                            );
                            return;
                          }
                          final amountNgn = amount / currency.rateFromNgn;
                          final txController = context
                              .read<TransactionController>();
                          await dashboard.creditBalance(
                            amountNgn,
                            sender: 'Wallet Top Up',
                          );
                          txController.addTransaction(
                            TransactionModel(
                              id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                              title: 'Wallet Top Up',
                              category: 'Income',
                              amount: amountNgn,
                              date: DateTime.now(),
                              status: TransactionStatus.completed,
                              type: TransactionType.inflow,
                              referenceNumber:
                                  'TP${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                              recipientName: 'TapPay Wallet',
                              note: 'Added via ${currency.code}',
                            ),
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHomeBody() {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final chipBg = isDark ? AppColors.darkSurface : const Color(0xFFF3F5F4);
    final kycBg = isDark ? AppColors.lightSurface : AppColors.darkBackground;
    final kycTitleColor = isDark
        ? AppColors.lightTextPrimary
        : AppColors.darkTextPrimary;
    final kycSubColor = isDark
        ? AppColors.lightTextSecondary
        : AppColors.darkTextSecondary;

    final auth = context.watch<AuthController>();
    final dashboard = context.watch<DashboardController>();
    final kyc = context.watch<KycController>();
    final transactionsController = context.watch<TransactionController>();

    final firstName = auth.signUpDraft.firstName.trim().isEmpty
        ? 'Jimmy'
        : auth.signUpDraft.firstName.trim();
    final currency = dashboard.selectedCurrency;
    final transactions = transactionsController.filteredTransactions;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: chipBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.person_rounded, size: 20, color: titleColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hi, $firstName',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),
              InkWell(
                onTap: _showSelectCurrencySheet,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlagIcon(
                        assetPath: currency.flagAsset,
                        fallbackEmoji: currency.flagEmoji,
                        width: 20,
                        height: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currency.code,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: titleColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Account Balance',
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subColor,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Flexible(
                child: Text(
                  dashboard.isBalanceMasked
                      ? '${currency.symbol}•••••••'
                      : dashboard.formattedActiveBalance,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => dashboard.toggleBalanceMask(),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: dashboard.isBalanceMasked
                      ? Icon(
                          Icons.visibility_outlined,
                          size: 20,
                          color: titleColor,
                        )
                      : SvgPicture.asset(
                          AppAssets.iconEyeSlash,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            titleColor,
                            BlendMode.srcIn,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DashboardActionChip(
                label: isDark ? 'Fund Wallet' : 'Add Money',
                svgAsset: AppAssets.iconPlus,
                backgroundColor: chipBg,
                foregroundColor: titleColor,
                onTap: _showFundWalletSheet,
              ),
              _DashboardActionChip(
                label: 'Send Money',
                svgAsset: AppAssets.iconPaperPlane,
                backgroundColor: chipBg,
                foregroundColor: titleColor,
                onTap: _showSendMoneyOptionsSheet,
              ),
              InkWell(
                onTap: _showMoreQuickActionsSheet,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    AppAssets.iconOption,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(titleColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          if (!kyc.profile.isVerified) ...[
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ImageVerificationIntroScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      color: kycBg,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Complete your account setup',
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: kycTitleColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Make all transactions by completing your KYC',
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 11,
                                    color: kycSubColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SvgPicture.asset(
                            AppAssets.iconArrowRight,
                            width: 18,
                            height: 18,
                            colorFilter: ColorFilter.mode(
                              kycTitleColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: -10,
                      bottom: -15,
                      child: IgnorePointer(
                        child: SvgPicture.asset(
                          AppAssets.iconLineLeft,
                          width: 80,
                          height: 70,
                          colorFilter: ColorFilter.mode(
                            isDark
                                ? Colors.black.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.15),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: -10,
                      child: IgnorePointer(
                        child: SvgPicture.asset(
                          AppAssets.iconLineRight,
                          width: 80,
                          height: 50,
                          colorFilter: ColorFilter.mode(
                            isDark
                                ? Colors.black.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.15),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              if (transactions.isNotEmpty)
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TransactionsLedgerScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 56),
              alignment: Alignment.center,
              child: Text(
                "You haven't performed any\ntransactions yet",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 13,
                  height: 1.5,
                  color: subColor,
                ),
              ),
            )
          else
            Column(
              children: transactions.take(5).map((tx) {
                final isOutflow = tx.isOutflow;
                final convertedAmount = tx.amount * currency.rateFromNgn;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    borderRadius: 12,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReceiptScreen(transaction: tx),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isOutflow
                                ? AppColors.accentRed.withValues(alpha: 0.12)
                                : AppColors.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isOutflow
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 18,
                            color: isOutflow
                                ? AppColors.accentRed
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormatter.formatShort(tx.date),
                                style: TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 11,
                                  color: subColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${isOutflow ? '-' : '+'}${CurrencyFormatter.format(convertedAmount, symbol: currency.symbol)}',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isOutflow ? titleColor : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildP2PBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'P2P & QR Transfers',
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Send or receive instant TapPay transfers seamlessly.',
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 13,
              color: subColor,
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QrScannerScreen()),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan to Pay',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Scan any TapPay QR code',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: subColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QrGeneratorScreen()),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receive with QR',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Share your payment QR code',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: subColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BeneficiariesScreen()),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.alternate_email_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send via TapTag',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Instant free transfer to TapPay tags',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: subColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final themeController = context.watch<ThemeController>();
    final auth = context.watch<AuthController>();
    final kyc = context.watch<KycController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                ),
                Switch(
                  value: themeController.isDarkMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (_) => themeController.toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePinScreen()),
              );
            },
            child: Row(
              children: [
                const Icon(Icons.pin_outlined, color: AppColors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction PIN',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      Text(
                        'Update your 4-digit security PIN',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: subColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TwoFactorSetupScreen()),
              );
            },
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Two-Factor Authentication',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      Text(
                        auth.settings.isTwoFactorEnabled
                            ? '${auth.settings.twoFactorMethod.badge} enabled'
                            : 'Protect logins with 2FA',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: subColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ImageVerificationIntroScreen(),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(
                  Icons.face_retouching_natural,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KYC Verification',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      Text(
                        kyc.profile.isVerified ? 'Verified' : 'Pending setup',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          color: kyc.profile.isVerified
                              ? AppColors.primary
                              : subColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: subColor,
                ),
              ],
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
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final navBg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final body = switch (_currentTab) {
      0 => _buildHomeBody(),
      1 => _buildP2PBody(),
      _ => _buildSettingsBody(),
    };

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(child: ResponsiveContainer(maxWidth: 680, child: body)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: borderColor, width: 0.6)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: _BottomNavItem(
                    icon: _currentTab == 0
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                    label: 'Home',
                    isSelected: _currentTab == 0,
                    unselectedColor: subColor,
                    onTap: () => setState(() => _currentTab = 0),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.groups_outlined,
                    label: 'P2P',
                    isSelected: _currentTab == 1,
                    unselectedColor: subColor,
                    onTap: () => setState(() => _currentTab = 1),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    icon: _currentTab == 2
                        ? Icons.settings_rounded
                        : Icons.settings_outlined,
                    label: 'Settings',
                    isSelected: _currentTab == 2,
                    unselectedColor: subColor,
                    onTap: () => setState(() => _currentTab = 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardActionChip extends StatelessWidget {
  final String label;
  final String svgAsset;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _DashboardActionChip({
    required this.label,
    required this.svgAsset,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: foregroundColor,
              ),
            ),
            const SizedBox(width: 6),
            SvgPicture.asset(
              svgAsset,
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _SheetOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: titleColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 13,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color unselectedColor;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : unselectedColor;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
