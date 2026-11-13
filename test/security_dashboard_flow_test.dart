import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tappay/app/theme/theme_controller.dart';
import 'package:tappay/core/security/biometrics_service.dart';
import 'package:tappay/core/storage/preferences_service.dart';
import 'package:tappay/core/storage/secure_storage_service.dart';
import 'package:tappay/features/auth/presentation/screens/create_pin_screen.dart';
import 'package:tappay/features/auth/presentation/screens/setup_biometrics_screen.dart';
import 'package:tappay/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:tappay/features/dashboard/presentation/screens/send_money_beneficiaries_screen.dart';
import 'package:tappay/features/dashboard/presentation/screens/send_money_form_screen.dart';
import 'package:tappay/features/kyc/presentation/screens/image_verification_capture_screen.dart';
import 'package:tappay/features/kyc/presentation/screens/image_verification_intro_screen.dart';
import 'package:tappay/features/kyc/presentation/screens/image_verification_thank_you_screen.dart';
import 'package:tappay/features/transactions/data/transaction_repository.dart';
import 'package:tappay/main.dart';

class _InMemorySecureStorage extends SecureStorageService {
  String? _pin;
  bool _biometrics = true;
  bool _twoFactor = true;
  String _twoFactorType = 'SMS';
  String? _token;

  @override
  Future<void> savePin(String pin) async => _pin = pin;

  @override
  Future<String?> getPin() async => _pin;

  @override
  Future<bool> hasPin() async => _pin != null && _pin!.isNotEmpty;

  @override
  Future<void> deletePin() async => _pin = null;

  @override
  Future<void> setBiometricsEnabled(bool enabled) async =>
      _biometrics = enabled;

  @override
  Future<bool> isBiometricsEnabled() async => _biometrics;

  @override
  Future<void> setTwoFactorEnabled(bool enabled, {String type = 'SMS'}) async {
    _twoFactor = enabled;
    _twoFactorType = type;
  }

  @override
  Future<bool> isTwoFactorEnabled() async => _twoFactor;

  @override
  Future<String> getTwoFactorType() async => _twoFactorType;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> clearAll() async {
    _pin = null;
    _token = null;
  }
}

class _MockBiometricsService extends BiometricsService {
  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<bool> authenticate({
    String reason = 'Authenticate to access TapPay secure features',
  }) async => true;
}

Future<PreferencesService> _initMockPrefs({bool isDark = false}) async {
  SharedPreferences.setMockInitialValues({
    'tappay_theme_mode': isDark ? 'dark' : 'light',
  });
  return PreferencesService.init();
}

Widget _wrapWithApp(PreferencesService prefs, Widget home) {
  return TapPayRoot(
    preferencesService: prefs,
    secureStorageService: _InMemorySecureStorage(),
    biometricsService: _MockBiometricsService(),
    transactionRepository: MockTransactionRepository(),
    initialHome: home,
  );
}

void main() {
  testWidgets(
    'CreatePinScreen validates mismatch, confirms PIN, and reaches Dashboard',
    (WidgetTester tester) async {
      final prefs = await _initMockPrefs();
      await tester.pumpWidget(_wrapWithApp(prefs, const CreatePinScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Create PIN'), findsOneWidget);

      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.tap(find.text('3'));
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm PIN'), findsOneWidget);

      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.tap(find.text('3'));
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      expect(find.text('PINs do not match. Try again.'), findsOneWidget);

      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.tap(find.text('3'));
      await tester.tap(find.text('4'));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      expect(find.byType(SetupBiometricsScreen), findsOneWidget);
      expect(find.text('Set up Biometrics'), findsOneWidget);

      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Image verification intro, capture, and thank you flow works', (
    WidgetTester tester,
  ) async {
    final prefs = await _initMockPrefs();
    await tester.pumpWidget(
      _wrapWithApp(prefs, const ImageVerificationIntroScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Image verification'), findsOneWidget);
    expect(find.text('Take a selfie'), findsOneWidget);

    await tester.tap(find.text('Take a selfie'));
    await tester.pumpAndSettle();

    expect(find.byType(ImageVerificationCaptureScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('capture_selfie_button')));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.byType(ImageVerificationThankYouScreen), findsOneWidget);
    expect(find.text('Thank you!'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Dashboard Light & Dark render, currency sheet swaps, and Send Money succeeds',
    (WidgetTester tester) async {
      final darkPrefs = await _initMockPrefs(isDark: true);
      await tester.pumpWidget(_wrapWithApp(darkPrefs, const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Hi, Jimmy'), findsOneWidget);
      expect(find.text('Fund Wallet'), findsOneWidget);
      expect(find.text('Send Money'), findsOneWidget);
      expect(find.text('Complete your account setup'), findsOneWidget);

      final themeController = tester
          .element(find.byType(TapPayApp))
          .read<ThemeController>();
      await themeController.toggleTheme();
      await tester.pumpAndSettle();

      expect(find.text('Add Money'), findsOneWidget);
      expect(find.text('NGN'), findsOneWidget);
      expect(find.text('₦6,000,000.00'), findsOneWidget);

      await tester.tap(find.text('NGN'));
      await tester.pumpAndSettle();

      expect(find.text('Select Currency'), findsOneWidget);
      expect(find.text('United States Dollar (USD)'), findsOneWidget);

      await tester.tap(find.text('United States Dollar (USD)'));
      await tester.pumpAndSettle();

      expect(find.text('USD'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Account details'), findsOneWidget);
      expect(find.text('Swap Currencies'), findsOneWidget);
      expect(find.text('Account Statement'), findsOneWidget);

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Money'));
      await tester.pumpAndSettle();

      expect(find.text('TapPay'), findsOneWidget);
      expect(find.text('Send to bank'), findsOneWidget);

      await tester.tap(find.text('TapPay'));
      await tester.pumpAndSettle();

      expect(find.byType(BeneficiariesScreen), findsOneWidget);
      expect(find.text('New account'), findsOneWidget);

      await tester.tap(find.text('New account'));
      await tester.pumpAndSettle();

      expect(find.byType(SendMoneyFormScreen), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '@johndoe');
      await tester.enterText(textFields.at(1), '100');
      await tester.enterText(textFields.at(2), 'Lunch');
      await tester.pumpAndSettle();

      expect(find.text('Johndoe'), findsOneWidget);

      await tester.tap(find.text('Save to beneficiaries'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send money'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('Transfer Successful'), findsOneWidget);
    },
  );
}
