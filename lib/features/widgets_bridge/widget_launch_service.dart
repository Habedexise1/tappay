import 'dart:async';

import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

class WidgetLaunchService {
  WidgetLaunchService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('tappay/widget_link');

  static const String scheme = 'tappay';
  static const String scannerHost = 'qr_scanner';

  final MethodChannel _channel;
  final StreamController<Uri> _links = StreamController<Uri>.broadcast();
  StreamSubscription<Uri?>? _pluginSubscription;

  Stream<Uri> get links => _links.stream;

  static bool isScannerLink(Uri? uri) =>
      uri != null && uri.scheme == scheme && uri.host == scannerHost;

  Future<Uri?> start() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLink' && call.arguments is String) {
        _emit(Uri.tryParse(call.arguments as String));
      }
    });

    try {
      _pluginSubscription = HomeWidget.widgetClicked.listen(
        _emit,
        onError: (Object _) {},
      );
    } catch (_) {}

    final fromPlugin = await _safe(HomeWidget.initiallyLaunchedFromHomeWidget);
    if (fromPlugin != null) return fromPlugin;

    final fromScene = await _safe(
      () => _channel.invokeMethod<String>('getInitialLink'),
    );
    return fromScene == null ? null : Uri.tryParse(fromScene);
  }

  void _emit(Uri? uri) {
    if (uri != null && !_links.isClosed) _links.add(uri);
  }

  Future<T?> _safe<T>(Future<T?> Function() call) async {
    try {
      return await call();
    } catch (_) {
      return null;
    }
  }

  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);
    await _pluginSubscription?.cancel();
    await _links.close();
  }
}
