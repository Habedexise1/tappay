import 'package:flutter/foundation.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({required this.storage});

  final SecureStorageService storage;

  static const String defaultPin = '1234';
  static const String _devPinOverride = String.fromEnvironment(
    'TAPPAY_DEV_PIN',
  );

  @override
  Future<SecuritySettings> loadSecuritySettings() async {
    final hasPin = await storage.hasPin();

    if (kDebugMode && _devPinOverride.length == 4) {
      await storage.savePin(_devPinOverride);
    } else if (!hasPin) {
      await storage.savePin(defaultPin);
    }

    final biometricsEnabled = await storage.isBiometricsEnabled();
    final twoFactorEnabled = await storage.isTwoFactorEnabled();
    final methodName = await storage.getTwoFactorType();

    return SecuritySettings(
      isPinSet: true,
      isBiometricsEnabled: biometricsEnabled,
      isTwoFactorEnabled: twoFactorEnabled,
      twoFactorMethod: TwoFactorMethod.values.firstWhere(
        (m) => m.badge.toLowerCase() == methodName.toLowerCase(),
        orElse: () => TwoFactorMethod.sms,
      ),
    );
  }

  @override
  Future<void> register({required String password}) async {
    await storage.savePassword(password);
    await storage.saveToken(_newToken());
  }

  @override
  Future<void> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await storage.saveToken(_newToken());
  }

  @override
  Future<void> requestPasswordReset(String email) =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  @override
  Future<void> savePin(String pin) => storage.savePin(pin);

  @override
  Future<bool> verifyPin(String pin) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return pin == (await storage.getPin() ?? defaultPin);
  }

  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (currentPin != (await storage.getPin() ?? defaultPin)) {
      throw const AuthException('Current PIN is incorrect', 'invalid_pin');
    }
    await storage.savePin(newPin);
  }

  @override
  Future<void> setBiometricsEnabled(bool enabled) =>
      storage.setBiometricsEnabled(enabled);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final saved = await storage.getPassword();
    if (saved != null && saved.isNotEmpty && saved != currentPassword) {
      throw const AuthException(
        'Current password is incorrect',
        'invalid_password',
      );
    }
    await storage.savePassword(newPassword);
  }

  @override
  Future<bool> verifyOtp(String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    return otp.length == 6;
  }

  @override
  Future<void> updateTwoFactor({
    required bool enabled,
    required TwoFactorMethod method,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await storage.setTwoFactorEnabled(enabled, type: method.badge);
  }

  @override
  Future<void> saveTwoFactorSecret(String secret) =>
      storage.saveTwoFactorSecret(secret);

  @override
  Future<void> signOut({bool wipeDevice = false}) =>
      wipeDevice ? storage.clearAll() : storage.deleteToken();

  String _newToken() => 'tappay_token_${DateTime.now().millisecondsSinceEpoch}';
}
