import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/result_state_screen.dart';
import '../../../auth/presentation/widgets/onboarding_step_header.dart';
import '../../../qr_transfer/presentation/qr_transfer_controller.dart';
import '../../../transactions/presentation/screens/receipt_screen.dart';
import '../../domain/dashboard_models.dart';
import '../dashboard_controller.dart';

class SendMoneyFormScreen extends StatefulWidget {
  final Beneficiary? preselectedBeneficiary;
  final bool isBankTransfer;

  const SendMoneyFormScreen({
    super.key,
    this.preselectedBeneficiary,
    this.isBankTransfer = false,
  });

  @override
  State<SendMoneyFormScreen> createState() => _SendMoneyFormScreenState();
}

class _SendMoneyFormScreenState extends State<SendMoneyFormScreen> {
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _saveToBeneficiaries = false;
  bool _isSending = false;
  String? _tagError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    final beneficiary = widget.preselectedBeneficiary;
    if (beneficiary != null) {
      _tagController.text = beneficiary.handle;
    }
  }

  @override
  void dispose() {
    _tagController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _resolveAccountName(List<Beneficiary> beneficiaries) {
    final raw = _tagController.text.trim();
    if (raw.isEmpty) return 'Account name';

    final normalized = widget.isBankTransfer || raw.startsWith('@')
        ? raw.toLowerCase()
        : '@${raw.toLowerCase()}';

    for (final b in beneficiaries) {
      if (b.handle.toLowerCase() == normalized) {
        return b.name;
      }
    }

    final clean = raw.replaceFirst('@', '').trim();
    if (clean.isEmpty) return 'Account name';
    if (widget.isBankTransfer) {
      return 'Account Verified';
    }
    return clean[0].toUpperCase() + clean.substring(1);
  }

  Future<void> _submitTransfer() async {
    final rawTag = _tagController.text.trim();
    final parsedAmount = double.tryParse(
      _amountController.text.trim().replaceAll(',', ''),
    );

    setState(() {
      _tagError = rawTag.isEmpty
          ? (widget.isBankTransfer
                ? 'Enter an account number'
                : 'Enter a TapTag')
          : null;
      _amountError = (parsedAmount == null || parsedAmount <= 0)
          ? 'Enter a valid amount'
          : null;
    });

    if (_tagError != null || _amountError != null) return;

    final dashboard = context.read<DashboardController>();
    final qrController = context.read<QrTransferController>();

    final currency = dashboard.selectedCurrency;
    final amountInNgn = parsedAmount! / currency.rateFromNgn;

    if (amountInNgn > dashboard.balance) {
      setState(() => _amountError = 'Insufficient account balance');
      return;
    }

    final resolvedName = _resolveAccountName(dashboard.beneficiaries);
    final handle = widget.isBankTransfer || rawTag.startsWith('@')
        ? rawTag
        : '@$rawTag';

    setState(() => _isSending = true);

    qrController.setRecipient(
      name: resolvedName == 'Account name' ? handle : resolvedName,
      handle: handle,
      amount: amountInNgn,
    );

    if (_saveToBeneficiaries) {
      dashboard.addBeneficiary(
        name: resolvedName == 'Account name' ? handle : resolvedName,
        handle: handle,
      );
    }

    final tx = await qrController.executeTransfer(
      amount: amountInNgn,
      note: '',
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (tx != null) {
      final navigator = Navigator.of(context);
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultStateScreen(
            isSuccess: true,
            title: 'Transfer Successful',
            subtitle:
                '${CurrencyFormatter.format(parsedAmount, symbol: currency.symbol)} sent to ${tx.recipientName}',
            summaryDetails: {
              'Recipient': tx.recipientName,
              'Reference': tx.referenceNumber,
              'Amount': CurrencyFormatter.format(
                parsedAmount,
                symbol: currency.symbol,
              ),
              'Status': tx.status.label,
            },
            primaryButtonText: 'View Receipt',
            onPrimaryPressed: () {
              navigator.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ReceiptScreen(transaction: tx),
                ),
              );
            },
            secondaryButtonText: 'Back to Home',
            onSecondaryPressed: () {
              navigator.popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultStateScreen(
            isSuccess: false,
            title: 'Transfer Failed',
            subtitle: 'We could not complete your transfer. Please try again.',
            primaryButtonText: 'Try Again',
            onPrimaryPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final dashboard = context.watch<DashboardController>();
    final resolvedAccountName = _resolveAccountName(dashboard.beneficiaries);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 520,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const OnboardingStepHeader(),
                      const SizedBox(height: 20),
                      Text(
                        'Send Money',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: widget.isBankTransfer
                            ? 'Account Number'
                            : 'TapTag',
                        hintText: widget.isBankTransfer
                            ? '0123456789'
                            : '@johndoe',
                        controller: _tagController,
                        errorText: _tagError,
                        onChanged: (_) => setState(() => _tagError = null),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          resolvedAccountName,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _tagController.text.trim().isEmpty
                                ? subColor
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Amount (${dashboard.selectedCurrency.code})',
                        hintText: '0.00',
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        errorText: _amountError,
                        onChanged: (_) => setState(() => _amountError = null),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _saveToBeneficiaries = !_saveToBeneficiaries;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: _saveToBeneficiaries
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _saveToBeneficiaries
                                      ? AppColors.primary
                                      : borderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: _saveToBeneficiaries
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: AppColors.lightTextPrimary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Save to beneficiaries',
                              style: TextStyle(
                                fontFamily: 'Gordita',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: AppButton(
                  text: 'Send money',
                  isLoading: _isSending,
                  onPressed: _submitTransfer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
