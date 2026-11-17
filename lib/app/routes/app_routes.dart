import 'package:flutter/material.dart';

import '../../features/qr_transfer/presentation/screens/qr_generator_screen.dart';
import '../../features/qr_transfer/presentation/screens/qr_scanner_screen.dart';
import '../../features/transactions/presentation/screens/transactions_ledger_screen.dart';

abstract final class AppRoutes {
  static const String qrScanner = '/qr_scanner';
  static const String qrGenerator = '/qr_generator';
  static const String transactions = '/transactions';

  static Route<void>? onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      qrScanner => const QrScannerScreen(),
      qrGenerator => const QrGeneratorScreen(),
      transactions => const TransactionsLedgerScreen(),
      _ => null,
    };
    if (page == null) return null;
    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }
}
