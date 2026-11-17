import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/view_state.dart';
import '../../../core/widgets/result_state_screen.dart';
import '../../qr_transfer/presentation/qr_transfer_controller.dart';
import '../../transactions/presentation/screens/receipt_screen.dart';
import 'dashboard_controller.dart';
import 'widgets/confirm_pin_sheet.dart';
import 'widgets/enter_amount_sheet.dart';

Future<void> startTransferFlow(
  BuildContext context, {
  required String recipientName,
  required String recipientDetail,
  bool isBankTransfer = false,
  String? note,
}) async {
  var amount = 0.0;

  while (true) {
    final entered = await EnterAmountSheet.show(
      context,
      recipientName: recipientName,
      recipientDetail: recipientDetail,
      initialAmount: amount,
    );
    if (entered == null || !context.mounted) return;
    amount = entered;

    final result = await ConfirmPinSheet.show(context);
    if (!context.mounted) return;
    if (result == ConfirmPinResult.back) continue;
    if (result != ConfirmPinResult.verified) return;
    break;
  }

  final dashboard = context.read<DashboardController>();
  final qr = context.read<QrTransferController>();
  final navigator = Navigator.of(context);
  final currency = dashboard.selectedCurrency;
  final category = isBankTransfer ? 'Bank Transfer' : 'Transfer';

  qr.setRecipient(name: recipientName, handle: recipientDetail);

  await _submit(
    navigator,
    qr,
    amountNgn: amount / currency.rateFromNgn,
    displayAmount: CurrencyFormatter.format(amount, symbol: currency.symbol),
    note: note ?? (isBankTransfer ? 'Bank Transfer' : 'TapPay Transfer'),
    category: category,
  );
}

Future<void> _submit(
  NavigatorState navigator,
  QrTransferController qr, {
  required double amountNgn,
  required String displayAmount,
  required String note,
  required String category,
}) async {
  showDialog<void>(
    context: navigator.context,
    barrierDismissible: false,
    useRootNavigator: false,
    builder: (_) => const PopScope(canPop: false, child: _ProcessingDialog()),
  );

  final tx = await qr.submitTransfer(
    amount: amountNgn,
    note: note,
    category: category,
  );

  navigator.pop();

  if (tx != null) {
    navigator.popUntil((route) => route.isFirst);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ResultStateScreen(
          isSuccess: true,
          title: 'Transfer Successful',
          subtitle: '$displayAmount sent to ${tx.recipientName}',
          summaryDetails: {
            'Recipient': tx.recipientName,
            'Reference': tx.referenceNumber,
            'Amount': displayAmount,
            'Status': tx.status.label,
          },
          primaryButtonText: 'View Receipt',
          onPrimaryPressed: () => navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => ReceiptScreen(transaction: tx)),
          ),
          secondaryButtonText: 'Back to Home',
          onSecondaryPressed: () {
            qr.resetTransfer();
            navigator.popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
    return;
  }

  final message = switch (qr.transferState) {
    Failure(:final message) => message,
    _ => 'We could not complete your transfer. Please try again.',
  };

  navigator.push(
    MaterialPageRoute(
      builder: (_) => ResultStateScreen(
        isSuccess: false,
        title: 'Transfer Failed',
        subtitle: message,
        primaryButtonText: 'Try Again',
        onPrimaryPressed: () {
          navigator.pop();
          _submit(
            navigator,
            qr,
            amountNgn: amountNgn,
            displayAmount: displayAmount,
            note: note,
            category: category,
          );
        },
        secondaryButtonText: 'Cancel',
        onSecondaryPressed: () {
          qr.resetTransfer();
          navigator.pop();
        },
      ),
    ),
  );
}

class _ProcessingDialog extends StatelessWidget {
  const _ProcessingDialog();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark
          ? AppColors.darkSurface
          : AppColors.lightBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Processing transfer…',
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Securely confirming with your bank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
