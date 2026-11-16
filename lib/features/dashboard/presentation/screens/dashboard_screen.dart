import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/flag_icon.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../kyc/presentation/kyc_controller.dart';
import '../../../kyc/presentation/screens/image_verification_intro_screen.dart';
import '../../../qr_transfer/presentation/screens/qr_generator_screen.dart';
import '../../../qr_transfer/presentation/screens/qr_scanner_screen.dart';
import '../../../settings/presentation/settings_tab.dart';
import '../../../transactions/presentation/screens/receipt_screen.dart';
import '../../../transactions/presentation/screens/transactions_ledger_screen.dart';
import '../../../transactions/presentation/transaction_controller.dart';
import '../../domain/dashboard_models.dart';
import '../dashboard_controller.dart';
import 'cards/add_by_card_screen.dart';
import 'send_money_beneficiaries_screen.dart';
import 'send_to_bank_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;

  void _showSelectCurrencySheet() {
    showAppBottomSheet<void>(
      context: context,
      title: 'Select Currency',
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: WalletCurrency.values.map((currency) {
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
          }).toList(),
        );
      },
    );
  }

  void _showSendMoneyOptionsSheet() {
    showAppBottomSheet<void>(
      context: context,
      title: 'Send Money',
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetOptionTile(
              svgAsset: AppAssets.iconPaperPlane,
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
              svgAsset: AppAssets.iconPaperPlane,
              title: isDark ? 'Other Banks' : 'Send to bank',
              subtitle: 'Send money to external account',
              cardBg: cardBg,
              borderColor: borderColor,
              titleColor: titleColor,
              subtitleColor: subColor,
              onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SendToBankScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showMoreQuickActionsSheet() {
    showAppBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetOptionTile(
              svgAsset: AppAssets.iconWallet2,
              title: 'Account details',
              subtitle: 'View your account informations',
              cardBg: cardBg,
              borderColor: borderColor,
              titleColor: titleColor,
              subtitleColor: subColor,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _SheetOptionTile(
              svgAsset: AppAssets.iconArrowSwap,
              title: 'Swap Currencies',
              subtitle: 'Convert to another currency',
              cardBg: cardBg,
              borderColor: borderColor,
              titleColor: titleColor,
              subtitleColor: subColor,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _SheetOptionTile(
              svgAsset: AppAssets.iconReceiptText,
              title: 'Account Statement',
              subtitle: 'Generate a statement of your transactions',
              cardBg: cardBg,
              borderColor: borderColor,
              titleColor: titleColor,
              subtitleColor: subColor,
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  void _showBankTransferSheet() {
    final auth = context.read<AuthController>();
    final firstName = auth.signUpDraft.firstName.trim().isEmpty
        ? 'Jimmy'
        : auth.signUpDraft.firstName.trim();
    final lastName = auth.signUpDraft.lastName.trim();
    final fullName = lastName.isEmpty ? firstName : '$firstName $lastName';
    const accountNumber = '1234567890';
    const bankName = 'Providus';
    bool copied = false;

    showAppBottomSheet<void>(
      context: context,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final titleColor = isDark ? AppColors.darkTextPrimary : Colors.black;
        final subColor = isDark
            ? AppColors.darkTextSecondary
            : AppColors.glassBlue;
        final cardBg = isDark
            ? const Color(0xFF162821)
            : const Color(0xFFF1F5F9);
        final borderColor = const Color(0xFF94A3B8);

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Transfer',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use the details below to receive money into your TapPaywallet',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 14,
                    height: 1.4,
                    color: subColor,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bank',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bankName,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: subColor,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Number',
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: titleColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  accountNumber,
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 12,

                                    color: subColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            key: const ValueKey('copy_account_number_btn'),
                            onTap: () {
                              Clipboard.setData(
                                const ClipboardData(text: accountNumber),
                              );
                              HapticFeedback.lightImpact();
                              setSheetState(() => copied = true);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Account number copied to clipboard',
                                    ),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                              Future.delayed(const Duration(seconds: 2), () {
                                if (sheetContext.mounted) {
                                  try {
                                    setSheetState(() => copied = false);
                                  } catch (_) {}
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: copied
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 22,
                                      color: AppColors.primary,
                                    )
                                  : SvgPicture.asset(
                                      AppAssets.iconCopy,
                                      width: 22,
                                      height: 22,
                                      colorFilter: ColorFilter.mode(
                                        titleColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Account Name',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fullName.isEmpty ? 'John Doe' : fullName,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,

                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddMoneyOptionsSheet() {
    showAppBottomSheet<void>(
      context: context,
      title: 'Add Money',
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final titleColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        final subColor = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
        final cardBg = isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC);
        final borderColor = isDark
            ? AppColors.darkBorder
            : const Color(0xFFF1F5F9);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AddMoneyOptionTile(
              leading: SvgPicture.asset(
                AppAssets.iconMoneyReceive,
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(titleColor, BlendMode.srcIn),
              ),
              title: 'Bank Transfer',
              subtitle: 'Receive money with you account number',
              cardBg: cardBg,
              borderColor: borderColor,
              titleColor: titleColor,
              subtitleColor: subColor,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showBankTransferSheet();
              },
            ),
            const SizedBox(height: 12),
            _AddMoneyOptionTile(
              leading: SvgPicture.asset(
                AppAssets.iconCardAdd,
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(titleColor, BlendMode.srcIn),
              ),
              title: 'Card',
              subtitle: 'Fund wallet using a debit card',
              cardBg: cardBg,
              borderColor: borderColor,
              titleColor: titleColor,
              subtitleColor: subColor,
              onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddByCardScreen()),
                );
              },
            ),
          ],
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
                onTap: _showAddMoneyOptionsSheet,
              ),
              _DashboardActionChip(
                key: const ValueKey('send_money_chip_btn'),
                label: 'Send Money',
                svgAsset: AppAssets.iconPaperPlane,
                backgroundColor: chipBg,
                foregroundColor: titleColor,
                onTap: _showSendMoneyOptionsSheet,
              ),
              InkWell(
                key: const ValueKey('more_quick_actions_btn'),
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

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final body = switch (_currentTab) {
      0 => _buildHomeBody(),
      1 => _buildP2PBody(),
      _ => SettingsTab(onExit: () => setState(() => _currentTab = 0)),
    };

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(child: ResponsiveContainer(maxWidth: 680, child: body)),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        items: const [
          AppNavItem(
            label: 'Home',
            activeSvg: AppAssets.navHomeActive,
            inactiveSvg: AppAssets.navHomeInactive,
          ),
          AppNavItem(
            label: 'P2P',
            activeSvg: AppAssets.navP2P,
            inactiveSvg: AppAssets.navP2P,
          ),
          AppNavItem(
            label: 'Settings',
            activeSvg: AppAssets.navSettingsActive,
            inactiveSvg: AppAssets.navSettingsInactive,
          ),
        ],
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
    super.key,
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
  final String svgAsset;
  final String title;
  final String subtitle;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _SheetOptionTile({
    required this.svgAsset,
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
            SvgPicture.asset(
              svgAsset,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(titleColor, BlendMode.srcIn),
            ),
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

class _AddMoneyOptionTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _AddMoneyOptionTile({
    required this.leading,
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 0.8),
        ),
        child: Row(
          children: [
            SizedBox(width: 32, height: 32, child: Center(child: leading)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 12,
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
