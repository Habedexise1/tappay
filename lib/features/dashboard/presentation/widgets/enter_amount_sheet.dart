import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_num_pad.dart';
import '../dashboard_controller.dart';

/// Bottom sheet for keying in a transfer amount.
///
/// Pops with the entered amount (in the selected display currency), or `null`
/// when the user goes back / dismisses the sheet.
class EnterAmountSheet extends StatefulWidget {
  final String recipientName;
  final String recipientDetail;
  final double initialAmount;

  const EnterAmountSheet({
    super.key,
    required this.recipientName,
    required this.recipientDetail,
    this.initialAmount = 0,
  });

  static Future<double?> show(
    BuildContext context, {
    required String recipientName,
    required String recipientDetail,
    double initialAmount = 0,
  }) {
    return showAppBottomSheet<double>(
      context: context,
      showDragHandle: false,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      maxWidth: 520,
      expand: true,
      builder: (_) => EnterAmountSheet(
        recipientName: recipientName,
        recipientDetail: recipientDetail,
        initialAmount: initialAmount,
      ),
    );
  }

  @override
  State<EnterAmountSheet> createState() => _EnterAmountSheetState();
}

class _EnterAmountSheetState extends State<EnterAmountSheet> {
  late int _cents = (widget.initialAmount * 100).round();
  String? _errorText;

  double get _amount => _cents / 100.0;

  void _onDigitPressed(String digit) {
    if (_cents >= 1000000000) return;
    setState(() {
      _errorText = null;
      _cents = _cents * 10 + int.parse(digit);
    });
  }

  void _onDeletePressed() {
    if (_cents == 0) return;
    setState(() {
      _errorText = null;
      _cents = _cents ~/ 10;
    });
  }

  void _confirm() {
    if (_amount <= 0) {
      setState(() => _errorText = 'Enter an amount greater than 0');
      return;
    }

    final dashboard = context.read<DashboardController>();
    final amountInNgn = _amount / dashboard.selectedCurrency.rateFromNgn;
    if (amountInNgn > dashboard.balance) {
      setState(() => _errorText = 'Insufficient account balance');
      return;
    }

    Navigator.of(context).pop(_amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final recipientColor = isDark
        ? AppColors.darkTextSecondary
        : const Color(0xFF64748B);

    final currency = context.watch<DashboardController>().selectedCurrency;
    final formatted = CurrencyFormatter.format(
      _amount,
      symbol: currency.symbol,
    );

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    key: const ValueKey('enter_amount_back_btn'),
                    icon: Icon(Icons.arrow_back, size: 26, color: textPrimary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 4),
                Image.asset(AppAssets.nairaArt, width: 72, height: 72),
                const SizedBox(height: 12),
                Text(
                  'Enter amount',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.recipientName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: recipientColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.recipientDetail,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: recipientColor,
                  ),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatted,
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  child: _errorText == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _errorText!,
                            style: const TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accentRed,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 28),
                const Spacer(),
                AppNumPad(
                  style: AppNumPadStyle.rounded,
                  onDigitPressed: _onDigitPressed,
                  onDeletePressed: _onDeletePressed,
                ),
                const SizedBox(height: 28),
                AppButton(
                  key: const ValueKey('enter_amount_confirm_btn'),
                  text: 'Confirm',
                  onPressed: _amount > 0 ? _confirm : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
