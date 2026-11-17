import '../../../core/network/network_simulator.dart';
import '../domain/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions();

  Future<TransactionModel> executeTransfer({
    required String recipient,
    required double amount,
    required String note,
    required String idempotencyKey,
    String category = 'Transfer',
  });
}

class MockTransactionRepository implements TransactionRepository {
  MockTransactionRepository({
    this.network = const NetworkSimulator(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final NetworkSimulator network;
  final DateTime Function() _clock;

  final List<TransactionModel> _ledger = [];
  final Map<String, TransactionModel> _settled = {};
  final Map<String, Future<TransactionModel>> _inFlight = {};

  int get ledgerSize => _ledger.length;

  @override
  Future<List<TransactionModel>> getTransactions() => network.request(
    'transactions.list',
    () => List<TransactionModel>.unmodifiable(_ledger),
    latencyOverride: const Duration(milliseconds: 800),
  );

  @override
  Future<TransactionModel> executeTransfer({
    required String recipient,
    required double amount,
    required String note,
    required String idempotencyKey,
    String category = 'Transfer',
  }) {
    final settled = _settled[idempotencyKey];
    if (settled != null) return Future.value(settled);

    final pending = _inFlight[idempotencyKey];
    if (pending != null) return pending;

    final request = network
        .request('transfers.create', () {
          final now = _clock();
          final tx = TransactionModel(
            id: 'tx_${now.microsecondsSinceEpoch}',
            title: 'Payment to $recipient',
            category: category,
            amount: amount,
            date: now,
            status: TransactionStatus.completed,
            type: TransactionType.outflow,
            referenceNumber: _referenceFor(idempotencyKey, now),
            fee: 0.00,
            recipientName: recipient,
            note: note.isNotEmpty ? note : category,
          );
          _settled[idempotencyKey] = tx;
          _ledger.insert(0, tx);
          return tx;
        })
        .whenComplete(() {
          _inFlight.remove(idempotencyKey);
        });

    _inFlight[idempotencyKey] = request;
    return request;
  }

  String _referenceFor(String key, DateTime now) {
    final suffix = key.hashCode.toUnsigned(20).toRadixString(16).toUpperCase();
    return 'REF-${now.millisecondsSinceEpoch.toString().substring(7)}$suffix';
  }
}
