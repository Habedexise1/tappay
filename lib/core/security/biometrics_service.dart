import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricsService {
  final LocalAuthentication _auth;

  BiometricsService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  Future<bool> canAuthenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

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
