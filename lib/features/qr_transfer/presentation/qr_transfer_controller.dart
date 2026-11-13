import 'package:flutter/foundation.dart';
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

  QrTransferController({
    required this.repository,
    required this.biometrics,
    required this.dashboardController,
    required this.transactionController,
  });

  ViewState<TransactionModel> _transferState = const Initial();
  ViewState<TransactionModel> get transferState => _transferState;

  QrTransferPayload? _scannedPayload;
  QrTransferPayload? get scannedPayload => _scannedPayload;

  bool _isTorchOn = false;
  bool get isTorchOn => _isTorchOn;

  String? _inFlightIdempotencyKey;

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
    final payload = _scannedPayload;
    if (payload == null) {
      _transferState = const Failure('No recipient selected');
      notifyListeners();
      return null;
    }

    if (amount <= 0) {
      _transferState = const Failure(
        'Transfer amount must be greater than zero',
      );
      notifyListeners();
      return null;
    }

    if (amount > dashboardController.balance) {
      _transferState = const Failure('Insufficient funds in account balance');
      notifyListeners();
      return null;
    }

    final authenticated = await biometrics.authenticate(
      reason:
          'Confirm transfer of \$${amount.toStringAsFixed(2)} to ${payload.recipient}',
    );

    if (!authenticated) {
      _transferState = const Failure(
        'Biometric verification cancelled or failed',
      );
      notifyListeners();
      return null;
    }

    final idempotencyKey =
        'idemp_${payload.accountHandle}_${amount}_${DateTime.now().millisecondsSinceEpoch}';
    if (_inFlightIdempotencyKey != null) {
      return null;
    }
    _inFlightIdempotencyKey = idempotencyKey;

    _transferState = const Loading('Processing secure transfer...');
    notifyListeners();

    try {
      final tx = await repository.executeTransfer(
        recipient: payload.recipient,
        amount: amount,
        note: note.isNotEmpty ? note : (payload.note ?? 'Transfer'),
        idempotencyKey: idempotencyKey,
      );

      await dashboardController.deductBalance(
        amount,
        recipient: payload.recipient,
      );
      transactionController.addTransaction(tx);

      _transferState = Success(tx);
      _inFlightIdempotencyKey = null;
      notifyListeners();
      return tx;
    } catch (e) {
      _transferState = Failure('Transfer failed: $e');
      _inFlightIdempotencyKey = null;
      notifyListeners();
      return null;
    }
  }

  void resetTransfer() {
    _transferState = const Initial();
    _scannedPayload = null;
    _inFlightIdempotencyKey = null;
    notifyListeners();
  }
}
