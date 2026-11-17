import 'auth_models.dart';

abstract interface class AuthRepository {
  Future<SecuritySettings> loadSecuritySettings();

  Future<void> register({required String password});

  Future<void> login({required String email, required String password});

  Future<void> requestPasswordReset(String email);

  Future<void> savePin(String pin);

  Future<bool> verifyPin(String pin);

  Future<void> changePin({required String currentPin, required String newPin});

  Future<void> setBiometricsEnabled(bool enabled);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<bool> verifyOtp(String otp);

  Future<void> updateTwoFactor({
    required bool enabled,
    required TwoFactorMethod method,
  });

  Future<void> saveTwoFactorSecret(String secret);

  Future<void> signOut({bool wipeDevice = false});
}
