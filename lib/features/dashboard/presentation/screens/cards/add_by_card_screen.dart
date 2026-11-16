import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../transactions/domain/transaction_model.dart';
import '../../../../transactions/presentation/transaction_controller.dart';
import '../../../domain/dashboard_models.dart';
import '../../dashboard_controller.dart';
import 'saved_cards_screen.dart';

class AddByCardScreen extends StatefulWidget {
  const AddByCardScreen({super.key});

  @override
  State<AddByCardScreen> createState() => _AddByCardScreenState();
}

class _AddByCardScreenState extends State<AddByCardScreen> {
  final TextEditingController _amountController = TextEditingController();
  PaymentCard? _selectedCard;
  String? _amountError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final dashboard = context.read<DashboardController>();
    _selectedCard = dashboard.selectedCard ??
        (dashboard.savedCards.isNotEmpty ? dashboard.savedCards.first : null);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickCard() async {
    final card = await Navigator.of(context).push<PaymentCard>(
      MaterialPageRoute(
        builder: (_) => const SavedCardsScreen(selectMode: true),
      ),
    );
    if (card != null && mounted) {
      setState(() => _selectedCard = card);
    }
  }

  Future<void> _submit() async {
    final rawAmount = _amountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(rawAmount);

    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Please enter a valid amount');
      return;
    }

    if (_selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add a card first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _pickCard();
      return;
    }

    setState(() {
      _amountError = null;
      _isSubmitting = true;
    });

    final dashboard = context.read<DashboardController>();
    final currency = dashboard.selectedCurrency;
    final amountNgn = amount / currency.rateFromNgn;

    await dashboard.creditBalance(
      amountNgn,
      sender: 'Card ending ${_selectedCard!.last4Digits}',
    );

    if (!mounted) return;

    final txController = context.read<TransactionController>();
    txController.addTransaction(
      TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Card Deposit',
        category: 'Income',
        amount: amountNgn,
        date: DateTime.now(),
        status: TransactionStatus.completed,
        type: TransactionType.inflow,
        referenceNumber:
            'TP${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        recipientName: 'TapPay Wallet',
        note: 'Funded via card ending in ${_selectedCard!.last4Digits}',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Successfully added ${currency.symbol}${amount.toStringAsFixed(2)} to wallet',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final placeholderColor = isDark
        ? const Color(0xFF6B7280)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? const Color(0xFF44554C)
        : const Color(0xFF1E293B);

    final dashboard = context.watch<DashboardController>();
    final activeCard = _selectedCard ?? dashboard.selectedCard;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                key: const ValueKey('add_by_card_back_btn'),
                icon: Icon(
                  Icons.arrow_back,
                  size: 26,
                  color: textPrimary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 20),
              Text(
                'Add by card',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Amount',
                        controller: _amountController,
                        errorText: _amountError,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Fee: 1.5% of deposit amount',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Card',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        key: const ValueKey('select_card_selector_btn'),
                        onTap: _pickCard,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.transparent : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: borderColor,
                              width: 1.1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  activeCard == null
                                      ? 'Select card'
                                      : activeCard.maskedNumber,
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 14,
                                    fontWeight: activeCard == null
                                        ? FontWeight.w400
                                        : FontWeight.w500,
                                    color: activeCard == null
                                        ? placeholderColor
                                        : textPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: textPrimary,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppButton(
                  text: 'Add money',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
