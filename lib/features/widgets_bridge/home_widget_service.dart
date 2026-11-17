import 'package:home_widget/home_widget.dart';

abstract interface class HomeWidgetSync {
  Future<void> syncBalance(String formattedBalance);

  Future<void> syncLastTransaction({
    required String formattedBalance,
    required String formattedAmount,
    required String merchant,
    required String date,
  });
}

class HomeWidgetService implements HomeWidgetSync {
  const HomeWidgetService();

  static const String appGroupId = 'group.com.example.tappay';
  static const String androidWidgetName = 'TapPayWidgetProvider';
  static const String iOSWidgetName = 'TapPayWidget';

  static const String keyBalance = 'widget_balance';
  static const String keyLastAmount = 'widget_last_amount';
  static const String keyLastMerchant = 'widget_last_merchant';
  static const String keyLastDate = 'widget_last_date';

  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (_) {}
  }

  @override
  Future<void> syncBalance(String formattedBalance) async {
    try {
      await HomeWidget.saveWidgetData<String>(keyBalance, formattedBalance);
      await _refresh();
    } catch (_) {}
  }

  @override
  Future<void> syncLastTransaction({
    required String formattedBalance,
    required String formattedAmount,
    required String merchant,
    required String date,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>(keyBalance, formattedBalance),
        HomeWidget.saveWidgetData<String>(keyLastAmount, formattedAmount),
        HomeWidget.saveWidgetData<String>(keyLastMerchant, merchant),
        HomeWidget.saveWidgetData<String>(keyLastDate, date),
      ]);
      await _refresh();
    } catch (_) {}
  }

  Future<void> _refresh() =>
      HomeWidget.updateWidget(name: androidWidgetName, iOSName: iOSWidgetName);
}
