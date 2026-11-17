import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tappay/app/theme/theme_controller.dart';
import 'package:tappay/core/network/network_simulator.dart';
import 'package:tappay/core/security/biometrics_service.dart';
import 'package:tappay/core/storage/preferences_service.dart';
import 'package:tappay/core/storage/secure_storage_service.dart';
import 'package:tappay/core/widgets/app_bottom_nav_bar.dart';
import 'package:tappay/core/widgets/result_state_screen.dart';
import 'package:tappay/features/auth/presentation/screens/create_pin_screen.dart';
import 'package:tappay/features/auth/presentation/screens/setup_biometrics_screen.dart';
import 'package:tappay/features/dashboard/presentation/widgets/confirm_pin_sheet.dart';
import 'package:tappay/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:tappay/features/dashboard/presentation/widgets/enter_amount_sheet.dart';
import 'package:tappay/features/dashboard/presentation/screens/send_money_beneficiaries_screen.dart';
import 'package:tappay/features/dashboard/presentation/screens/send_money_recipient_screen.dart';
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
    transactionRepository: MockTransactionRepository(
      network: const NetworkSimulator.instant(),
    ),
    initialHome: home,
  );
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('home_widget'),
          (MethodCall methodCall) async => true,
        );
  });

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

  testWidgets(
    'Dashboard Light & Dark render, currency sheet swaps, and Send Money succeeds',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

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

      await tester.tap(find.byKey(const ValueKey('more_quick_actions_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Account details'), findsOneWidget);
      expect(find.text('Swap Currencies'), findsOneWidget);
      expect(find.text('Account Statement'), findsOneWidget);

      Navigator.of(tester.element(find.text('Account Statement'))).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('send_money_chip_btn')));
      await tester.pumpAndSettle();

      expect(find.text('TapPay'), findsOneWidget);
      expect(find.text('Send to bank'), findsOneWidget);

      await tester.tap(find.text('TapPay'));
      await tester.pumpAndSettle();

      expect(find.byType(BeneficiariesScreen), findsOneWidget);
      expect(find.text('New account'), findsOneWidget);

      await tester.tap(find.text('New account'));
      await tester.pumpAndSettle();

      expect(find.byType(SendMoneyRecipientScreen), findsOneWidget);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '@johndoe');
      await tester.pumpAndSettle();

      expect(find.text('Johndoe'), findsOneWidget);

      await tester.tap(find.text('Save as beneficiary'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send money'));
      await tester.pumpAndSettle();

      expect(find.byType(EnterAmountSheet), findsOneWidget);
      Finder inSheet<T>(Finder f) =>
          find.descendant(of: find.byType(T), matching: f);
      expect(
        inSheet<EnterAmountSheet>(find.text('Enter amount')),
        findsOneWidget,
      );
      expect(inSheet<EnterAmountSheet>(find.text('Johndoe')), findsOneWidget);

      for (final d in ['1', '0', '0', '0', '0']) {
        await tester.tap(inSheet<EnterAmountSheet>(find.text(d)));
        await tester.pumpAndSettle();
      }

      await tester.tap(inSheet<EnterAmountSheet>(find.text('Confirm')));
      await tester.pumpAndSettle();

      expect(find.byType(EnterAmountSheet), findsNothing);
      expect(find.byType(ConfirmPinSheet), findsOneWidget);
      expect(
        inSheet<ConfirmPinSheet>(find.text('Confirm PIN')),
        findsOneWidget,
      );

      for (final d in ['1', '2', '3', '4']) {
        await tester.tap(inSheet<ConfirmPinSheet>(find.text(d)));
        await tester.pumpAndSettle();
      }

      expect(find.byType(ConfirmPinSheet), findsNothing);
      expect(find.byType(SendMoneyRecipientScreen), findsNothing);
      expect(find.byType(ResultStateScreen), findsOneWidget);
      expect(find.text('Transfer Successful'), findsOneWidget);

      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();

      expect(find.byType(ResultStateScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
    },
  );

  testWidgets('Dashboard adapts between phone and tablet breakpoints', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1280, 800);

    final prefs = await _initMockPrefs();
    await tester.pumpWidget(_wrapWithApp(prefs, const DashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(AppSideNavRail), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsNothing);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();

    expect(find.byType(AppSideNavRail), findsNothing);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
