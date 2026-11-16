import 'package:flutter/material.dart';

import 'screens/settings_home_screen.dart';

class SettingsTab extends StatefulWidget {
  final VoidCallback onExit;

  const SettingsTab({super.key, required this.onExit});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settingsNav');

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) {
        final nav = _navigatorKey.currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        } else {
          widget.onExit();
        }
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => SettingsHomeScreen(onBack: widget.onExit),
        ),
      ),
    );
  }
}
