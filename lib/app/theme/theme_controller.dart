import 'package:flutter/material.dart';
import '../../core/storage/preferences_service.dart';

class ThemeController extends ChangeNotifier {
  final PreferencesService _prefs;
  late ThemeMode _themeMode;

  ThemeController(this._prefs) {
    _themeMode = _prefs.getThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setThemeMode(mode);
  }

  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
