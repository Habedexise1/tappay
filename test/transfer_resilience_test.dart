import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tappay/core/errors/error_mapper.dart';
import 'package:tappay/core/errors/exceptions.dart';
import 'package:tappay/core/errors/failures.dart' as failures;
import 'package:tappay/core/network/network_simulator.dart';
import 'package:tappay/core/security/biometrics_service.dart';
import 'package:tappay/core/storage/preferences_service.dart';
import 'package:tappay/core/utils/view_state.dart';
import 'package:tappay/features/dashboard/presentation/dashboard_controller.dart';
import 'package:tappay/features/qr_transfer/presentation/qr_transfer_controller.dart';
import 'package:tappay/features/transactions/data/transaction_repository.dart';
import 'package:tappay/features/transactions/domain/transaction_model.dart';
import 'package:tappay/features/transactions/presentation/transaction_controller.dart';
import 'package:tappay/features/widgets_bridge/home_widget_service.dart';
import 'package:tappay/features/widgets_bridge/widget_launch_service.dart';

class _FakeBiometrics extends BiometricsService {
  bool approve = true;
  int prompts = 0;

  @override
  Future<bool> authenticate({
    String reason = 'Authenticate to access TapPay secure features',
  }) async {
    prompts++;
    return approve;
  }
}

class _RecordingWidgetSync implements HomeWidgetSync {
  final List<String> balances = [];
  final List<({String amount, String merchant})> transactions = [];

  @override
  Future<void> syncBalance(String formattedBalance) async {
    balances.add(formattedBalance);
  }

  @override
  Future<void> syncLastTransaction({
    required String formattedBalance,
    required String formattedAmount,
    required String merchant,
    required String date,
  }) async {
    balances.add(formattedBalance);
    transactions.add((amount: formattedAmount, merchant: merchant));
  }
}

class _Harness {
  _Harness._(
    this.repository,
    this.biometrics,
    this.widgetSync,
    this.dashboard,
    this.transactions,
    this.controller,
  );

  final MockTransactionRepository repository;
  final _FakeBiometrics biometrics;
  final _RecordingWidgetSync widgetSync;
  final DashboardController dashboard;
  final TransactionController transactions;
  final QrTransferController controller;

  static Future<_Harness> create({FailurePolicy? failurePolicy}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesService.init();
    final repository = MockTransactionRepository(
      network: NetworkSimulator.instant(failurePolicy: failurePolicy),
    );
    final biometrics = _FakeBiometrics();
    final widgetSync = _RecordingWidgetSync();
    final dashboard = DashboardController(
      prefs: prefs,
      biometrics: biometrics,
      widgetSync: widgetSync,
    );
    final transactions = TransactionController(repository: repository);
    await pumpEventQueue();

    var nonce = 0;
    final controller = QrTransferController(
      repository: repository,
      biometrics: biometrics,
      dashboardController: dashboard,
      transactionController: transactions,
      nonceGenerator: () => 'n${nonce++}',
    );
    return _Harness._(
      repository,
      biometrics,
      widgetSync,
      dashboard,
      transactions,
      controller,
    );
  }
}

void main() {
  group('MockTransactionRepository idempotency', () {
    late MockTransactionRepository repository;

    setUp(() {
      repository = MockTransactionRepository(
        network: const NetworkSimulator.instant(),
      );
    });

    Future<TransactionModel> send(String key, {double amount = 100}) =>
        repository.executeTransfer(
          recipient: 'Sarah Jenkins',
          amount: amount,
          note: '',
          idempotencyKey: key,
        );

    test('replaying a settled key returns the original transaction', () async {
      final first = await send('key-1');
      final replay = await send('key-1');

      expect(replay.id, first.id);
      expect(replay.referenceNumber, first.referenceNumber);
      expect(repository.ledgerSize, 1);
    });

    test('concurrent requests with the same key are coalesced', () async {
      final results = await Future.wait([send('key-2'), send('key-2')]);

      expect(results[0].id, results[1].id);
      expect(repository.ledgerSize, 1);
    });

    test('distinct keys create distinct ledger entries', () async {
      await send('key-a');
      await send('key-b');

      expect(repository.ledgerSize, 2);
      final ledger = await repository.getTransactions();
      expect(ledger.first.amount, 100);
    });

    test('a failed request is not recorded and can be retried', () async {
      var failNext = true;
      repository = MockTransactionRepository(
        network: NetworkSimulator.instant(
          failurePolicy: (_) {
            final fail = failNext;
            failNext = false;
            return fail;
          },
        ),
      );

      await expectLater(send('key-3'), throwsA(isA<NetworkException>()));
      expect(repository.ledgerSize, 0);

      final retried = await send('key-3');
      expect(retried.recipientName, 'Sarah Jenkins');
      expect(repository.ledgerSize, 1);
    });
  });

  group('QrTransferController state machine', () {
    test('successful transfer moves Initial -> Loading -> Success', () async {
      final h = await _Harness.create();
      final states = <ViewState<TransactionModel>>[];
      h.controller.addListener(() => states.add(h.controller.transferState));
      final startingBalance = h.dashboard.balance;

      h.controller.setRecipient(name: 'David Miller', handle: '@dmiller');
      final tx = await h.controller.executeTransfer(amount: 2500, note: '');

      expect(tx, isNotNull);
      expect(h.biometrics.prompts, 1);
      expect(states.whereType<Loading<TransactionModel>>(), hasLength(1));
      expect(h.controller.transferState, isA<Success<TransactionModel>>());
      expect(h.dashboard.balance, startingBalance - 2500);
      expect(h.transactions.filteredTransactions.first.id, tx!.id);
      expect(h.controller.pendingIdempotencyKey, isNull);
    });

    test('balance change is flushed to the home screen widget', () async {
      final h = await _Harness.create();

      h.controller.setRecipient(name: 'Elena Rostova', handle: '@erostova');
      await h.controller.executeTransfer(amount: 1000, note: '');

      expect(h.widgetSync.transactions, hasLength(1));
      expect(h.widgetSync.transactions.single.merchant, 'Elena Rostova');
      expect(h.widgetSync.transactions.single.amount, startsWith('-'));
      expect(h.widgetSync.balances.last, h.dashboard.formattedActiveBalance);
    });

    test('rejected biometrics fails without hitting the network', () async {
      final h = await _Harness.create();
      h.biometrics.approve = false;

      h.controller.setRecipient(name: 'Priya Sharma', handle: '@priyash');
      final tx = await h.controller.executeTransfer(amount: 10, note: '');

      expect(tx, isNull);
      expect(h.controller.transferState, isA<Failure<TransactionModel>>());
      expect(h.repository.ledgerSize, 0);
    });

    test('insufficient funds is rejected before authorisation', () async {
      final h = await _Harness.create();

      h.controller.setRecipient(name: 'Alexandre Chen', handle: '@alexc');
      final tx = await h.controller.executeTransfer(
        amount: h.dashboard.balance + 1,
        note: '',
      );

      expect(tx, isNull);
      expect(h.biometrics.prompts, 0);
      final state = h.controller.transferState as Failure<TransactionModel>;
      expect(state.message, contains('Insufficient'));
    });

    test('retry after a network failure reuses the idempotency key', () async {
      var failures = 1;
      final h = await _Harness.create(
        failurePolicy: (operation) =>
            operation == 'transfers.create' && failures-- > 0,
      );
      final startingBalance = h.dashboard.balance;

      h.controller.setRecipient(name: 'Sarah Jenkins', handle: '@sarahj');
      final first = await h.controller.submitTransfer(amount: 500, note: '');
      final keyAfterFailure = h.controller.pendingIdempotencyKey;

      expect(first, isNull);
      expect(h.controller.transferState, isA<Failure<TransactionModel>>());
      expect(keyAfterFailure, isNotNull);
      expect(h.dashboard.balance, startingBalance);

      final retry = await h.controller.submitTransfer(amount: 500, note: '');

      expect(retry, isNotNull);
      expect(h.repository.ledgerSize, 1);
      expect(h.dashboard.balance, startingBalance - 500);
    });

    test('a second submit while processing is ignored', () async {
      final h = await _Harness.create();
      h.controller.setRecipient(name: 'Sarah Jenkins', handle: '@sarahj');

      final results = await Future.wait([
        h.controller.submitTransfer(amount: 300, note: ''),
        h.controller.submitTransfer(amount: 300, note: ''),
      ]);

      expect(results.whereType<TransactionModel>(), hasLength(1));
      expect(h.repository.ledgerSize, 1);
    });
  });

  group('Error mapping and deep links', () {
    test('exceptions map to typed failures', () {
      expect(
        ErrorMapper.toFailure(const NetworkException()),
        isA<failures.NetworkFailure>(),
      );
      expect(
        ErrorMapper.toFailure(const InsufficientFundsException()),
        isA<failures.ValidationFailure>(),
      );
      expect(
        ErrorMapper.toFailure(StateError('boom')),
        isA<failures.ServerFailure>(),
      );
    });

    test('only tappay://qr_scanner links open the scanner', () {
      expect(
        WidgetLaunchService.isScannerLink(
          Uri.parse('tappay://qr_scanner?homeWidget'),
        ),
        isTrue,
      );
      expect(
        WidgetLaunchService.isScannerLink(Uri.parse('tappay://settings')),
        isFalse,
      );
      expect(
        WidgetLaunchService.isScannerLink(Uri.parse('https://qr_scanner')),
        isFalse,
      );
      expect(WidgetLaunchService.isScannerLink(null), isFalse);
    });
  });
}
