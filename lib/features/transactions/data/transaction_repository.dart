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
  final List<TransactionModel> _mockTransactions = [
    TransactionModel(
      id: 'tx_101',
      title: 'Apple Store',
      category: 'Electronics',
      amount: 199.99,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: TransactionStatus.completed,
      type: TransactionType.outflow,
      referenceNumber: 'REF-8392190',
      fee: 0.00,
      recipientName: 'Apple Inc.',
      note: 'MacBook accessory purchase',
    ),
    TransactionModel(
      id: 'tx_102',
      title: 'Salary Deposit',
      category: 'Income',
      amount: 4500.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: TransactionStatus.completed,
      type: TransactionType.inflow,
      referenceNumber: 'REF-2849102',
      fee: 0.00,
      recipientName: 'Stripe Corp',
      note: 'Monthly engineering compensation',
    ),
    TransactionModel(
      id: 'tx_103',
      title: 'Netflix Subscription',
      category: 'Entertainment',
      amount: 15.99,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: TransactionStatus.completed,
      type: TransactionType.outflow,
      referenceNumber: 'REF-9302194',
      fee: 0.00,
      recipientName: 'Netflix',
      note: 'Monthly Premium 4K plan',
    ),
    TransactionModel(
      id: 'tx_104',
      title: 'Transfer to Sarah Jenkins',
      category: 'Transfer',
      amount: 120.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: TransactionStatus.completed,
      type: TransactionType.outflow,
      referenceNumber: 'REF-5920194',
      fee: 0.50,
      recipientName: 'Sarah Jenkins',
      note: 'Dinner split',
    ),
    TransactionModel(
      id: 'tx_105',
      title: 'Starbucks Coffee',
      category: 'Food & Drink',
      amount: 8.75,
      date: DateTime.now().subtract(const Duration(days: 4)),
      status: TransactionStatus.completed,
      type: TransactionType.outflow,
      referenceNumber: 'REF-1092841',
      fee: 0.00,
      recipientName: 'Starbucks',
      note: 'Morning latte',
    ),
  ];

  @override
  Future<List<TransactionModel>> getTransactions() async {
    // 600ms latency for smooth ledger loading
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
    // 1.5s simulated network delay specified in assessment requirement
    await Future.delayed(const Duration(milliseconds: 1500));

    final newTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Payment to $recipient',
      category: 'Transfer',
      amount: amount,
      date: DateTime.now(),
      status: TransactionStatus.completed,
      type: TransactionType.outflow,
      referenceNumber: 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      fee: 0.00,
      recipientName: recipient,
      note: note.isNotEmpty ? note : 'QR Transfer',
    );

    _mockTransactions.insert(0, newTx);
    return newTx;
  }
}

