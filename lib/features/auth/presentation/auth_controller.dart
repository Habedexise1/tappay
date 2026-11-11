import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/security/biometrics_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/view_state.dart';
import '../domain/auth_models.dart';

/// Provider controller managing Authentication, PIN management, OTP recovery, and 2FA.
class AuthController extends ChangeNotifier {
  final SecureStorageService storage;
  final BiometricsService biometrics;

  AuthController({
    required this.storage,
    required this.biometrics,
  }) {
    _loadInitialSecurityState();
  }

  // --- States ---
  ViewState<SecuritySettings> _securityState = const Initial();
  ViewState<SecuritySettings> get securityState => _securityState;

  ViewState<bool> _pinActionState = const Initial();
  ViewState<bool> get pinActionState => _pinActionState;

  ViewState<bool> _otpState = const Initial();
  ViewState<bool> get otpState => _otpState;

  // --- OTP Timer ---
  int _otpCountdown = 60;
  int get otpCountdown => _otpCountdown;
  bool get canResendOtp => _otpCountdown == 0;
  Timer? _countdownTimer;

  SecuritySettings _settings = const SecuritySettings(
    isPinSet: true,
    isBiometricsEnabled: true,
    isTwoFactorEnabled: true,
    twoFactorMethod: TwoFactorMethod.sms,
  );
  SecuritySettings get settings => _settings;

  Future<void> _loadInitialSecurityState() async {
    _securityState = const Loading();
    notifyListeners();

    try {
      final hasPin = await storage.hasPin();
      // Default to 1234 if not set yet for demonstration ease
      if (!hasPin) {
        await storage.savePin('1234');
      }

      final biometricsEnabled = await storage.isBiometricsEnabled();
      final twoFactorEnabled = await storage.isTwoFactorEnabled();
      final methodStr = await storage.getTwoFactorType();

      final method = TwoFactorMethod.values.firstWhere(
        (m) => m.badge.toLowerCase() == methodStr.toLowerCase(),
        orElse: () => TwoFactorMethod.sms,
      );

      _settings = SecuritySettings(
        isPinSet: true,
        isBiometricsEnabled: biometricsEnabled,
        isTwoFactorEnabled: twoFactorEnabled,
        twoFactorMethod: method,
      );

      _securityState = Success(_settings);
      notifyListeners();
    } catch (e) {
      _securityState = Failure('Could not load security state: $e');
      notifyListeners();
    }
  }

  // --- PIN Operations ---
  Future<bool> verifyPin(String enteredPin) async {
    _pinActionState = const Loading('Verifying PIN...');
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final currentPin = await storage.getPin() ?? '1234';
    if (enteredPin == currentPin) {
      _pinActionState = const Success(true);
      notifyListeners();
      return true;
    } else {
      _pinActionState = const Failure('Incorrect PIN. Please try again.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    _pinActionState = const Loading('Updating PIN...');
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final savedPin = await storage.getPin() ?? '1234';
    if (currentPin != savedPin) {
      _pinActionState = const Failure('Current PIN is incorrect');
      notifyListeners();
      return false;
    }

    if (newPin.length != 4) {
      _pinActionState = const Failure('New PIN must be exactly 4 digits');
      notifyListeners();
      return false;
    }

    await storage.savePin(newPin);
    _settings = _settings.copyWith(isPinSet: true);
    _pinActionState = const Success(true);
    notifyListeners();
    return true;
  }

  // --- Biometrics Operations ---
  Future<bool> authenticateWithBiometrics({String reason = 'Authenticate for TapPay'}) async {
    final success = await biometrics.authenticate(reason: reason);
    return success;
  }

  Future<void> toggleBiometrics(bool enable) async {
    await storage.setBiometricsEnabled(enable);
    _settings = _settings.copyWith(isBiometricsEnabled: enable);
    notifyListeners();
  }

  // --- 2FA Operations ---
  Future<void> updateTwoFactor({
    required bool enabled,
    required TwoFactorMethod method,
  }) async {
    _securityState = const Loading('Updating 2FA Settings...');
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    await storage.setTwoFactorEnabled(enabled, type: method.badge);
    _settings = _settings.copyWith(
      isTwoFactorEnabled: enabled,
      twoFactorMethod: method,
    );
    _securityState = Success(_settings);
    notifyListeners();
  }

  // --- Password Recovery & OTP Timer ---
  void startOtpTimer() {
    _otpCountdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCountdown > 0) {
        _otpCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<bool> verifyOtp(String otp) async {
    _otpState = const Loading('Verifying code...');
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    if (otp == '123456' || otp.length == 6) {
      _otpState = const Success(true);
      notifyListeners();
      return true;
    } else {
      _otpState = const Failure('Invalid OTP code. Use test code 123456.');
      notifyListeners();
      return false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResendOtp) return;
    startOtpTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

