import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../transactions/domain/transaction_model.dart';
import '../../transactions/presentation/transaction_controller.dart';
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
  final txController = context.read<TransactionController>();
  final navigator = Navigator.of(context);
  final currency = dashboard.selectedCurrency;
  final amountNgn = amount / currency.rateFromNgn;

  await dashboard.deductBalance(amountNgn, recipient: recipientName);

  final now = DateTime.now();
  final tx = TransactionModel(
    id: 'tx_${now.millisecondsSinceEpoch}',
    title: 'Payment to $recipientName',
    category: isBankTransfer ? 'Bank Transfer' : 'Transfer',
    amount: amountNgn,
    date: now,
    status: TransactionStatus.completed,
    type: TransactionType.outflow,
    referenceNumber:
        'REF-${now.millisecondsSinceEpoch.toString().substring(5)}',
    fee: 0.00,
    recipientName: recipientName,
    note: note ?? (isBankTransfer ? 'Bank Transfer' : 'TapPay Transfer'),
  );
  txController.addTransaction(tx);

  navigator.popUntil((route) => route.isFirst);
}
