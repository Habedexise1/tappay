import 'package:flutter/widgets.dart';

class AppLifecycleObserver with WidgetsBindingObserver {
  AppLifecycleObserver({this.shieldEnabled = true});

  final bool shieldEnabled;
  final ValueNotifier<bool> isObscured = ValueNotifier<bool>(false);

  void attach() => WidgetsBinding.instance.addObserver(this);

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
    isObscured.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!shieldEnabled) return;
    isObscured.value = switch (state) {
      AppLifecycleState.inactive ||
      AppLifecycleState.paused ||
      AppLifecycleState.hidden => true,
      AppLifecycleState.resumed || AppLifecycleState.detached => false,
    };
  }
}
