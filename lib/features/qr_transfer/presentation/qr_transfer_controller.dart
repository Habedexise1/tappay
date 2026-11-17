import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/security/biometrics_service.dart';
import '../../../core/utils/view_state.dart';
import '../../dashboard/presentation/dashboard_controller.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_model.dart';
import '../../transactions/presentation/transaction_controller.dart';
import '../domain/qr_payload.dart';

class QrTransferController extends ChangeNotifier {
  final TransactionRepository repository;
  final BiometricsService biometrics;
  final DashboardController dashboardController;
  final TransactionController transactionController;
  final String Function() _nonce;

  QrTransferController({
    required this.repository,
    required this.biometrics,
    required this.dashboardController,
    required this.transactionController,
    String Function()? nonceGenerator,
  }) : _nonce =
           nonceGenerator ??
           (() => DateTime.now().microsecondsSinceEpoch.toRadixString(36));

  ViewState<TransactionModel> _transferState = const Initial();
  ViewState<TransactionModel> get transferState => _transferState;

  QrTransferPayload? _scannedPayload;
  QrTransferPayload? get scannedPayload => _scannedPayload;

  bool _isTorchOn = false;
  bool get isTorchOn => _isTorchOn;

  ({String fingerprint, String key})? _pendingIntent;

  String? get pendingIdempotencyKey => _pendingIntent?.key;

  bool get isProcessing => _transferState is Loading<TransactionModel>;

  void toggleTorch() {
    _isTorchOn = !_isTorchOn;
    notifyListeners();
  }

  void handleQrCodeScanned(String rawCode) {
    final payload = QrTransferPayload.fromRawString(rawCode);
    if (payload != null) {
      _scannedPayload = payload;
      notifyListeners();
    }
  }

  void setRecipient({
    required String name,
    required String handle,
    double? amount,
    String? note,
  }) {
    _scannedPayload = QrTransferPayload(
      recipient: name,
      accountHandle: handle,
      amount: amount,
      note: note,
    );
    notifyListeners();
  }

  Future<TransactionModel?> executeTransfer({
    required double amount,
    required String note,
  }) async {
    if (isProcessing) return null;
    if (!_validate(amount)) return null;

    final payload = _scannedPayload!;
    final authenticated = await biometrics.authenticate(
      reason:
          'Confirm transfer of \$${amount.toStringAsFixed(2)} to ${payload.recipient}',
    );

    if (!authenticated) {
      _emit(const Failure('Biometric verification cancelled or failed'));
      return null;
    }

    return submitTransfer(amount: amount, note: note);
  }

  Future<TransactionModel?> submitTransfer({
    required double amount,
    required String note,
    String category = 'Transfer',
  }) async {
    if (isProcessing) return null;
    if (!_validate(amount)) return null;

    final payload = _scannedPayload!;
    final key = _idempotencyKeyFor(payload, amount, category);

    _emit(const Loading('Processing secure transfer...'));

    try {
      final tx = await repository.executeTransfer(
        recipient: payload.recipient,
        amount: amount,
        note: note.isNotEmpty ? note : (payload.note ?? category),
        idempotencyKey: key,
        category: category,
      );

      await dashboardController.deductBalance(
        amount,
        recipient: payload.recipient,
      );
      transactionController.addTransaction(tx);

      _pendingIntent = null;
      _emit(Success(tx));
      return tx;
    } catch (error) {
      _emit(Failure(ErrorMapper.toFailure(error).message));
      return null;
    }
  }

  void resetTransfer() {
    _transferState = const Initial();
    _scannedPayload = null;
    _pendingIntent = null;
    notifyListeners();
  }

  bool _validate(double amount) {
    if (_scannedPayload == null) {
      _emit(const Failure('No recipient selected'));
      return false;
    }
    if (amount <= 0) {
      _emit(const Failure('Transfer amount must be greater than zero'));
      return false;
    }
    if (amount > dashboardController.balance) {
      _emit(const Failure('Insufficient funds in account balance'));
      return false;
    }
    return true;
  }

  String _idempotencyKeyFor(
    QrTransferPayload payload,
    double amount,
    String category,
  ) {
    final fingerprint =
        '${payload.accountHandle}|${amount.toStringAsFixed(2)}|$category';
    final current = _pendingIntent;
    if (current != null && current.fingerprint == fingerprint) {
      return current.key;
    }
    final key = 'idemp_${_nonce()}';
    _pendingIntent = (fingerprint: fingerprint, key: key);
    return key;
  }

  void _emit(ViewState<TransactionModel> state) {
    _transferState = state;
    notifyListeners();
  }
}
