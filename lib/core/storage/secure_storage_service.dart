import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  static const String _keyPin = 'tappay_secure_pin';
  static const String _keyBiometricEnabled = 'tappay_biometric_enabled';
  static const String _keyTwoFactorEnabled = 'tappay_two_factor_enabled';
  static const String _keyTwoFactorType = 'tappay_two_factor_type';
  static const String _keyAuthToken = 'tappay_auth_token';

  Future<void> savePin(String pin) async {
    await _storage.write(key: _keyPin, value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: _keyPin);
  }

  Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _keyPin);
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
  }

  Future<bool> isBiometricsEnabled() async {
    final val = await _storage.read(key: _keyBiometricEnabled);
    return val == 'true';
  }

  Future<void> setTwoFactorEnabled(bool enabled, {String type = 'SMS'}) async {
    await _storage.write(key: _keyTwoFactorEnabled, value: enabled.toString());
    await _storage.write(key: _keyTwoFactorType, value: type);
  }

  Future<bool> isTwoFactorEnabled() async {
    final val = await _storage.read(key: _keyTwoFactorEnabled);
    return val == 'true';
  }

  Future<String> getTwoFactorType() async {
    return await _storage.read(key: _keyTwoFactorType) ?? 'SMS';
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
