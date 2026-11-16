import '../domain/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel> executeTransfer({
    required String recipient,
    required double amount,
    required String note,
    required String idempotencyKey,
  });
}

class MockTransactionRepository implements TransactionRepository {
  final List<TransactionModel> _mockTransactions = [];

  @override
  Future<List<TransactionModel>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.unmodifiable(_mockTransactions);
  }

  @override
  Future<TransactionModel> executeTransfer({
    required String recipient,
    required double amount,
    required String note,
    required String idempotencyKey,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final newTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Payment to $recipient',
      category: 'Transfer',
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.completed,
      type: TransactionType.outflow,
      referenceNumber:
          'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      fee: 0.00,
      recipientName: recipient,
      note: note.isNotEmpty ? note : 'QR Transfer',
    );

    _mockTransactions.insert(0, newTx);
    return newTx;
  }
}
