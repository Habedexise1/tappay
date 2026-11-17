import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/security/biometrics_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/view_state.dart';
import '../data/mock_auth_repository.dart';
import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final SecureStorageService storage;
  final BiometricsService biometrics;
  final AuthRepository repository;

  AuthController({
    required this.storage,
    required this.biometrics,
    AuthRepository? repository,
  }) : repository = repository ?? MockAuthRepository(storage: storage) {
    _loadInitialSecurityState();
  }

  ViewState<SecuritySettings> _securityState = const Initial();
  ViewState<SecuritySettings> get securityState => _securityState;

  ViewState<bool> _pinActionState = const Initial();
  ViewState<bool> get pinActionState => _pinActionState;

  ViewState<bool> _otpState = const Initial();
  ViewState<bool> get otpState => _otpState;

  ViewState<bool> _authFlowState = const Initial();
  ViewState<bool> get authFlowState => _authFlowState;

  ViewState<bool> _passwordState = const Initial();
  ViewState<bool> get passwordState => _passwordState;

  String? _pendingTwoFactorSecret;

  String? get pendingTwoFactorSecret => _pendingTwoFactorSecret;

  SignUpDraft _signUpDraft = const SignUpDraft();
  SignUpDraft get signUpDraft => _signUpDraft;

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
      _settings = await repository.loadSecuritySettings();
      _securityState = Success(_settings);
      notifyListeners();
    } catch (e) {
      _securityState = Failure('Could not load security state: $e');
      notifyListeners();
    }
  }

  void updateSignUpContact({
    required String value,
    required bool isPhone,
    CountryOption? phoneCountry,
  }) {
    _signUpDraft = _signUpDraft.copyWith(
      contactValue: value,
      isPhoneContact: isPhone,
      phoneCountry: phoneCountry,
    );
    notifyListeners();
  }

  void updateSignUpName({required String firstName, required String lastName}) {
    _signUpDraft = _signUpDraft.copyWith(
      firstName: firstName,
      lastName: lastName,
    );
    notifyListeners();
  }

  void updateSignUpAddress({CountryOption? country, required String address}) {
    _signUpDraft = _signUpDraft.copyWith(country: country, address: address);
    notifyListeners();
  }

  void updateSignUpTapTag(String tag) {
    _signUpDraft = _signUpDraft.copyWith(tapTag: tag);
    notifyListeners();
  }

  void updateSignUpBvn(String bvn) {
    _signUpDraft = _signUpDraft.copyWith(bvn: bvn);
    notifyListeners();
  }

  Future<bool> completeSignUp(String password) async {
    if (password.length < 8) {
      _authFlowState = const Failure(
        'Password must be at least 8 alphanumeric and special characters.',
      );
      notifyListeners();
      return false;
    }

    _authFlowState = const Loading('Creating account...');
    notifyListeners();

    await repository.register(password: password);

    _authFlowState = const Success(true);
    notifyListeners();
    return true;
  }

  Future<bool> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    if (password.trim().isEmpty) {
      _authFlowState = const Failure('Please enter your password.');
      notifyListeners();
      return false;
    }

    _authFlowState = const Loading('Signing in...');
    notifyListeners();

    await repository.login(email: email, password: password);

    _authFlowState = const Success(true);
    notifyListeners();
    return true;
  }

  Future<bool> requestPasswordReset(String email) async {
    if (!email.contains('@')) {
      _authFlowState = const Failure('Enter a valid email address.');
      notifyListeners();
      return false;
    }

    _authFlowState = const Loading('Sending OTP...');
    notifyListeners();

    await repository.requestPasswordReset(email);

    _authFlowState = const Success(true);
    notifyListeners();
    return true;
  }

  Future<void> saveCreatedPin(String pin) async {
    await repository.savePin(pin);
    _settings = _settings.copyWith(isPinSet: true);
    _pinActionState = const Success(true);
    notifyListeners();
  }

  Future<bool> verifyPin(String enteredPin) async {
    _pinActionState = const Loading('Verifying PIN...');
    notifyListeners();

    if (await repository.verifyPin(enteredPin)) {
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
    if (newPin.length != 4) {
      _pinActionState = const Failure('New PIN must be exactly 4 digits');
      notifyListeners();
      return false;
    }

    _pinActionState = const Loading('Updating PIN...');
    notifyListeners();

    try {
      await repository.changePin(currentPin: currentPin, newPin: newPin);
    } catch (error) {
      _pinActionState = Failure(ErrorMapper.toFailure(error).message);
      notifyListeners();
      return false;
    }

    _settings = _settings.copyWith(isPinSet: true);
    _pinActionState = const Success(true);
    notifyListeners();
    return true;
  }

  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate for TapPay',
  }) async {
    final success = await biometrics.authenticate(reason: reason);
    return success;
  }

  Future<void> toggleBiometrics(bool enable) async {
    await repository.setBiometricsEnabled(enable);
    _settings = _settings.copyWith(isBiometricsEnabled: enable);
    notifyListeners();
  }

  Future<bool> setBiometricsEnabledSecurely(bool enable) async {
    final available = await biometrics.canAuthenticate();
    if (enable && !available) return false;
    if (available) {
      final ok = await biometrics.authenticate(
        reason: enable
            ? 'Confirm to enable biometric unlock'
            : 'Confirm to disable biometric unlock',
      );
      if (!ok) return false;
    }
    await toggleBiometrics(enable);
    return true;
  }

  static String? validateNewPassword(String password) {
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password)) {
      return 'Use a mix of letters and numbers';
    }
    return null;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_passwordState is Loading) return false;

    if (currentPassword.isEmpty) {
      _passwordState = const Failure('Enter your current password');
      notifyListeners();
      return false;
    }
    final error = validateNewPassword(newPassword);
    if (error != null) {
      _passwordState = Failure(error);
      notifyListeners();
      return false;
    }
    if (newPassword == currentPassword) {
      _passwordState = const Failure(
        'New password must differ from your current password',
      );
      notifyListeners();
      return false;
    }

    _passwordState = const Loading('Updating password...');
    notifyListeners();

    try {
      await repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (error) {
      _passwordState = Failure(ErrorMapper.toFailure(error).message);
      notifyListeners();
      return false;
    }

    _passwordState = const Success(true);
    notifyListeners();
    return true;
  }

  void resetPasswordState() {
    if (_passwordState is Initial) return;
    _passwordState = const Initial();
    notifyListeners();
  }

  String prepareTwoFactorSecret() {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = Random.secure();
    return _pendingTwoFactorSecret ??= List.generate(
      16,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  Future<bool> activateTwoFactor({
    required TwoFactorMethod method,
    required String otp,
  }) async {
    final ok = await verifyOtp(otp);
    if (!ok) return false;
    if (method == TwoFactorMethod.authenticator) {
      await repository.saveTwoFactorSecret(prepareTwoFactorSecret());
    }
    await updateTwoFactor(enabled: true, method: method);
    _pendingTwoFactorSecret = null;
    _countdownTimer?.cancel();
    return true;
  }

  Future<bool> deactivateTwoFactor(String otp) async {
    final ok = await verifyOtp(otp);
    if (!ok) return false;
    await updateTwoFactor(enabled: false, method: _settings.twoFactorMethod);
    _countdownTimer?.cancel();
    return true;
  }

  void resetOtpState() {
    if (_otpState is Initial) return;
    _otpState = const Initial();
    notifyListeners();
  }

  Future<void> signOut({bool wipeDevice = false}) async {
    _countdownTimer?.cancel();
    await repository.signOut(wipeDevice: wipeDevice);
    _authFlowState = const Initial();
    _pinActionState = const Initial();
    _otpState = const Initial();
    _passwordState = const Initial();
    _pendingTwoFactorSecret = null;
    notifyListeners();
  }

  Future<void> updateTwoFactor({
    required bool enabled,
    required TwoFactorMethod method,
  }) async {
    _securityState = const Loading('Updating 2FA Settings...');
    notifyListeners();

    await repository.updateTwoFactor(enabled: enabled, method: method);
    _settings = _settings.copyWith(
      isTwoFactorEnabled: enabled,
      twoFactorMethod: method,
    );
    _securityState = Success(_settings);
    notifyListeners();
  }

  void startOtpTimer({int seconds = 60}) {
    _otpCountdown = seconds;
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

    if (await repository.verifyOtp(otp)) {
      _otpState = const Success(true);
      notifyListeners();
      return true;
    } else {
      _otpState = const Failure('Invalid OTP code. Use test code 123456.');
      notifyListeners();
      return false;
    }
  }

  Future<void> resendOtp({int seconds = 60}) async {
    if (!canResendOtp) return;
    startOtpTimer(seconds: seconds);
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
