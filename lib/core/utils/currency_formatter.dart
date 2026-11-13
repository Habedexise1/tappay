import 'package:intl/intl.dart';

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

  static String format(double amount, {String symbol = '\$'}) {
    if (symbol != '\$') {
      final custom = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
      return custom.format(amount);
    }
    return _standardFormatter.format(amount);
  }

  static String formatCompact(double amount) {
    return _compactFormatter.format(amount);
  }

  static String mask() {
    return '••••••••';
  }
}
