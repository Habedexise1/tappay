import 'package:home_widget/home_widget.dart';
import '../../core/utils/currency_formatter.dart';

/// Service managing synchronization between Flutter state and native Home Screen Widgets
/// (Android AppWidgetProvider & iOS WidgetKit).
class HomeWidgetService {
  HomeWidgetService._();

  static const String appGroupId = 'group.com.example.tappay';
  static const String androidWidgetName = 'TapPayWidgetProvider';
  static const String iOSWidgetName = 'TapPayWidget';

  // Key constants used across Dart and native code
  static const String keyBalance = 'widget_balance';
  static const String keyLastAmount = 'widget_last_amount';
  static const String keyLastMerchant = 'widget_last_merchant';
  static const String keyLastDate = 'widget_last_date';

  /// Initialize HomeWidget App Group
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (_) {
      // Ignored on unsupported platforms / mock mode
    }
  }

  /// Sync latest balance and last transaction details to the native widget store.
  static Future<void> updateWidgetData({
    required double balance,
    required double lastAmount,
    required String lastMerchant,
    required String lastDate,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        keyBalance,
        CurrencyFormatter.format(balance),
      );
      await HomeWidget.saveWidgetData<String>(
        keyLastAmount,
        CurrencyFormatter.format(lastAmount),
      );
      await HomeWidget.saveWidgetData<String>(
        keyLastMerchant,
        lastMerchant,
      );
      await HomeWidget.saveWidgetData<String>(
        keyLastDate,
        lastDate,
      );

      // Trigger native widget refresh
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (_) {
      // Graceful fallback if native widget is not installed
    }
  }
}

