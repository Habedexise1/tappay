import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static const String _keyThemeMode = 'tappay_theme_mode';
  static const String _keyBalanceMasked = 'tappay_balance_masked';
  static const String _keyPrimaryBalance = 'tappay_primary_balance';

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  ThemeMode getThemeMode() {
    final modeStr = _prefs.getString(_keyThemeMode);
    return switch (modeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_keyThemeMode, str);
  }

  bool isBalanceMasked() {
    return _prefs.getBool(_keyBalanceMasked) ?? false;
  }

  Future<void> setBalanceMasked(bool masked) async {
    await _prefs.setBool(_keyBalanceMasked, masked);
  }

  double getPrimaryBalance() {
    return _prefs.getDouble(_keyPrimaryBalance) ?? 24580.50;
  }

  Future<void> setPrimaryBalance(double balance) async {
    await _prefs.setDouble(_keyPrimaryBalance, balance);
  }
}
