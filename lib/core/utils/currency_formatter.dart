import 'package:intl/intl.dart';

/// Formatter utilities for currency display and balance masking.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _standardFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 1,
  );

  /// Format an amount into standard currency display: e.g. "$12,450.80".
  static String format(double amount, {String symbol = '\$'}) {
    if (symbol != '\$') {
      final custom = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
      return custom.format(amount);
    }
    return _standardFormatter.format(amount);
  }

  /// Compact format for widgets or tight spaces: e.g. "$12.5K".
  static String formatCompact(double amount) {
    return _compactFormatter.format(amount);
  }

  /// Masked balance display for privacy (e.g. "••••••••").
  static String mask() {
    return '••••••••';
  }
}

