import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service wrapping [LocalAuthentication] to gate sensitive actions:
/// unmasking balance, approving transfers, changing PIN.
class BiometricsService {
  final LocalAuthentication _auth;

  BiometricsService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  /// Check if hardware supports biometric authentication and can check biometrics.
  Future<bool> canAuthenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Returns the list of enrolled biometrics (e.g. face, fingerprint).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Triggers biometric authentication with fallback to PIN/device password.
  Future<bool> authenticate({
    String reason = 'Authenticate to access TapPay secure features',
  }) async {
    try {
      final available = await canAuthenticate();
      if (!available) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}

