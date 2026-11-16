import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tappay/app/theme/theme_controller.dart';
import 'package:tappay/core/security/biometrics_service.dart';
import 'package:tappay/core/storage/preferences_service.dart';
import 'package:tappay/core/storage/secure_storage_service.dart';
import 'package:tappay/core/utils/view_state.dart';
import 'package:tappay/core/widgets/app_toggle.dart';
import 'package:tappay/core/widgets/success_pop_screen.dart';
import 'package:tappay/features/auth/domain/auth_models.dart';
import 'package:tappay/features/auth/presentation/auth_controller.dart';
import 'package:tappay/features/auth/presentation/screens/change_password_screen.dart';
import 'package:tappay/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:tappay/features/settings/data/mock_settings_repository.dart';
import 'package:tappay/features/settings/domain/settings_models.dart';
import 'package:tappay/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:tappay/features/settings/presentation/settings_controller.dart';
import 'package:tappay/features/settings/presentation/settings_tab.dart';
import 'package:tappay/features/transactions/data/transaction_repository.dart';
import 'package:tappay/main.dart';

class _MemorySecureStorage extends SecureStorageService {
  _MemorySecureStorage({this.twoFactor = false, this.password});

  String? pin = '1234';
  bool biometrics = true;
  bool twoFactor;
  String twoFactorType = 'SMS';
  String? token = 'token';
  String? password;
  String? secret;

  @override
  Future<void> savePin(String value) async => pin = value;
  @override
  Future<String?> getPin() async => pin;
  @override
  Future<bool> hasPin() async => pin != null && pin!.isNotEmpty;
  @override
  Future<void> deletePin() async => pin = null;
  @override
  Future<void> setBiometricsEnabled(bool enabled) async => biometrics = enabled;
  @override
  Future<bool> isBiometricsEnabled() async => biometrics;
  @override
  Future<void> setTwoFactorEnabled(bool enabled, {String type = 'SMS'}) async {
    twoFactor = enabled;
    twoFactorType = type;
  }

  @override
  Future<bool> isTwoFactorEnabled() async => twoFactor;
  @override
  Future<String> getTwoFactorType() async => twoFactorType;
  @override
  Future<void> saveToken(String value) async => token = value;
  @override
  Future<String?> getToken() async => token;
  @override
  Future<void> deleteToken() async => token = null;
  @override
  Future<void> savePassword(String value) async => password = value;
  @override
  Future<String?> getPassword() async => password;
  @override
  Future<void> saveTwoFactorSecret(String value) async => secret = value;
  @override
  Future<String?> getTwoFactorSecret() async => secret;
  @override
  Future<void> clearAll() async {
    pin = null;
    token = null;
    password = null;
    secret = null;
  }
}

class _AlwaysYesBiometrics extends BiometricsService {
  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<bool> authenticate({
    String reason = 'Authenticate to access TapPay secure features',
  }) async => true;
}

Future<PreferencesService> _prefs({bool dark = false}) async {
  SharedPreferences.setMockInitialValues({
    'tappay_theme_mode': dark ? 'dark' : 'light',
  });
  return PreferencesService.init();
}

Widget _app(
  PreferencesService prefs,
  Widget home, {
  _MemorySecureStorage? storage,
}) {
  return TapPayRoot(
    preferencesService: prefs,
    secureStorageService: storage ?? _MemorySecureStorage(),
    biometricsService: _AlwaysYesBiometrics(),
    transactionRepository: MockTransactionRepository(),
    initialHome: home,
  );
}

Widget _settingsHome() => Scaffold(body: SettingsTab(onExit: () {}));

void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder _field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(EditableText),
);

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}

Future<void> _enterPinDigits(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.text(digit).last);
    await tester.pump();
  }
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('home_widget'),
          (_) async => true,
        );
  });

  group('UserProfile.referralCodeFor', () {
    test('matches the Figma code for John Doe', () {
      expect(UserProfile.referralCodeFor('John Doe'), 'JHNDOE');
    });

    test('handles single names and empty input', () {
      expect(UserProfile.referralCodeFor('Ada'), 'ADA');
      expect(UserProfile.referralCodeFor('  '), 'TAPPAY');
    });
  });

  group('SettingsController', () {
    test('loads profile and account details', () async {
      final repo = MockSettingsRepository(
        prefs: await _prefs(),
        latency: Duration.zero,
      );
      final controller = SettingsController(repository: repo);
      await controller.load();

      expect(controller.profileState, isA<Success<UserProfile>>());
      expect(controller.profile!.handle, '@johndoe');
      expect(controller.accountState.dataOrNull!.accountNumber, '1234567890');
    });

    test('rejects invalid phone numbers and persists valid ones', () async {
      final prefs = await _prefs();
      final repo = MockSettingsRepository(prefs: prefs, latency: Duration.zero);
      final controller = SettingsController(repository: repo);
      await controller.load();

      expect(await controller.updatePhoneNumber('0812'), isFalse);
      expect(controller.phoneUpdateState, isA<Failure<bool>>());

      expect(await controller.updatePhoneNumber('+234 9011112222'), isTrue);
      expect(controller.profile!.phoneNumber, '+234 9011112222');

      final reloaded = SettingsController(repository: repo);
      await reloaded.load();
      expect(reloaded.profile!.phoneNumber, '+234 9011112222');
    });

    test('notification preferences persist across instances', () async {
      final prefs = await _prefs();
      final repo = MockSettingsRepository(prefs: prefs, latency: Duration.zero);
      final controller = SettingsController(repository: repo);

      await controller.setNotification(
        NotificationChannel.transactionPush,
        false,
      );

      final next = SettingsController(repository: repo);
      expect(
        next.notifications.isEnabled(NotificationChannel.transactionPush),
        isFalse,
      );
      expect(
        next.notifications.isEnabled(NotificationChannel.loginEmail),
        isTrue,
      );
    });

    test('sign-up details override the seeded profile', () async {
      final repo = MockSettingsRepository(
        prefs: await _prefs(),
        latency: Duration.zero,
      );
      final controller = SettingsController(repository: repo);
      await controller.load();

      controller.applySignUpDetails(
        firstName: 'Ada',
        lastName: 'Obi',
        tapTag: '@adaobi',
        email: 'ada@example.com',
      );

      final profile = controller.profile!;
      expect(profile.fullName, 'Ada Obi');
      expect(profile.handle, '@adaobi');
      expect(profile.email, 'ada@example.com');
      expect(profile.referralCode, 'ADOBI');
      expect(controller.accountState.dataOrNull!.accountName, 'Ada Obi');
    });
  });

  group('AuthController settings actions', () {
    AuthController buildAuth(_MemorySecureStorage storage) =>
        AuthController(storage: storage, biometrics: _AlwaysYesBiometrics());

    test('changePassword validates input and checks the current one', () async {
      final storage = _MemorySecureStorage(password: 'oldPass123');
      final auth = buildAuth(storage);

      expect(
        await auth.changePassword(
          currentPassword: 'oldPass123',
          newPassword: 'short',
        ),
        isFalse,
      );
      expect(
        (auth.passwordState as Failure<bool>).message,
        contains('8 characters'),
      );

      expect(
        await auth.changePassword(
          currentPassword: 'wrongPass1',
          newPassword: 'newPass456',
        ),
        isFalse,
      );
      expect(
        (auth.passwordState as Failure<bool>).message,
        'Current password is incorrect',
      );

      expect(
        await auth.changePassword(
          currentPassword: 'oldPass123',
          newPassword: 'newPass456',
        ),
        isTrue,
      );
      expect(storage.password, 'newPass456');
    });

    test('activates and deactivates two-factor authentication', () async {
      final storage = _MemorySecureStorage();
      final auth = buildAuth(storage);
      await Future<void>.delayed(Duration.zero);

      final secret = auth.prepareTwoFactorSecret();
      expect(secret, hasLength(16));
      expect(auth.prepareTwoFactorSecret(), secret, reason: 'stable per setup');

      expect(
        await auth.activateTwoFactor(
          method: TwoFactorMethod.authenticator,
          otp: '123456',
        ),
        isTrue,
      );
      expect(auth.settings.isTwoFactorEnabled, isTrue);
      expect(auth.settings.twoFactorMethod, TwoFactorMethod.authenticator);
      expect(storage.secret, secret);
      expect(auth.pendingTwoFactorSecret, isNull);

      expect(await auth.deactivateTwoFactor('654321'), isTrue);
      expect(auth.settings.isTwoFactorEnabled, isFalse);
      expect(storage.twoFactor, isFalse);
    });

    test('signOut clears the session; wipe removes credentials', () async {
      final storage = _MemorySecureStorage(password: 'pass1234');
      final auth = buildAuth(storage);

      await auth.signOut();
      expect(storage.token, isNull);
      expect(storage.pin, isNotNull);

      await auth.signOut(wipeDevice: true);
      expect(storage.pin, isNull);
      expect(storage.password, isNull);
    });
  });

  group('Settings UI', () {
    testWidgets('Settings tab keeps the bottom bar on sub-pages', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final prefs = await _prefs();
      await tester.pumpWidget(_app(prefs, const DashboardScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('@johndoe'), findsOneWidget);
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Account Information'), findsNothing);

      await _tapVisible(tester, find.text('Account'));
      expect(find.text('Account Information'), findsOneWidget);
      expect(
        find.text('Verified').evaluate().isNotEmpty ||
            find.text('Unverified').evaluate().isNotEmpty,
        isTrue,
      );

      await _tapVisible(tester, find.text('Notification'));
      expect(find.byType(NotificationSettingsScreen), findsOneWidget);
      expect(find.text('Home'), findsOneWidget, reason: 'bottom bar visible');

      await _tapVisible(
        tester,
        find.byKey(const ValueKey('settings_back_btn')),
      );
      expect(find.byType(NotificationSettingsScreen), findsNothing);
      expect(find.text('Account Information'), findsOneWidget);
    });

    testWidgets('notification toggles persist', (tester) async {
      _usePhoneViewport(tester);
      final prefs = await _prefs();
      await tester.pumpWidget(_app(prefs, const NotificationSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Push'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('notification_transactionPush')),
          matching: find.byType(AppToggle),
        ),
      );
      await tester.pumpAndSettle();

      expect(prefs.getFlag('notif_tx_push', defaultValue: true), isFalse);
      expect(prefs.getFlag('notif_login_email', defaultValue: true), isTrue);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('dark mode card switches and persists the theme', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final prefs = await _prefs();
      await tester.pumpWidget(_app(prefs, _settingsHome()));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SettingsTab));
      expect(context.read<ThemeController>().isDarkMode, isFalse);

      await _tapVisible(
        tester,
        find.descendant(
          of: find.byKey(const ValueKey('dark_mode_card')),
          matching: find.byType(AppToggle),
        ),
      );

      expect(context.read<ThemeController>().isDarkMode, isTrue);
      expect(prefs.getThemeMode(), ThemeMode.dark);
    });

    testWidgets('2FA: activate via SMS, then deactivate', (tester) async {
      _usePhoneViewport(tester);
      final prefs = await _prefs();
      final storage = _MemorySecureStorage(twoFactor: false);
      await tester.pumpWidget(_app(prefs, _settingsHome(), storage: storage));
      await tester.pumpAndSettle();

      await _tapVisible(tester, find.text('Security'));
      await _tapVisible(tester, find.text('Two-factor Authentication'));

      expect(
        find.textContaining('Add another layer of security'),
        findsOneWidget,
      );
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('two_factor_activate_btn')),
      );

      expect(find.text('SMS'), findsOneWidget);
      expect(find.text('Secret Key'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('two_factor_option_sms')));
      await tester.pumpAndSettle();

      expect(find.text('+234 8123456789'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('two_factor_send_otp_btn')));
      await _pumpFrames(tester);

      expect(find.text('Activate SMS'), findsOneWidget);
      expect(find.textContaining('Resend code in'), findsOneWidget);

      await tester.enterText(_field('two_factor_otp_input'), '123456');
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();

      expect(find.byType(SuccessPopScreen), findsOneWidget);
      expect(
        find.text('Your two-factor authentication SMS has been activated'),
        findsOneWidget,
      );
      expect(storage.twoFactor, isTrue);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('two_factor_deactivate_btn')));
      await _pumpFrames(tester);

      expect(find.text('Deactivate SMS'), findsOneWidget);
      await tester.enterText(_field('two_factor_otp_input'), '654321');
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();

      expect(
        find.text('Your two-factor authentication SMS has been deactivated'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(storage.twoFactor, isFalse);
      expect(find.byKey(const ValueKey('two_factor_activate_btn')), findsOne);
    });

    testWidgets('change password shows errors, then succeeds', (tester) async {
      _usePhoneViewport(tester);
      final prefs = await _prefs();
      final storage = _MemorySecureStorage(password: 'oldPass123');
      await tester.pumpWidget(
        _app(prefs, const ChangePasswordScreen(), storage: storage),
      );
      await tester.pumpAndSettle();

      final submit = find.byKey(const ValueKey('change_password_submit_btn'));

      await tester.enterText(_field('current_password_field'), 'wrongPass1');
      await tester.enterText(_field('new_password_field'), 'newPass456');
      await tester.pump();
      await tester.tap(submit);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();
      expect(find.text('Current password is incorrect'), findsOneWidget);

      await tester.enterText(_field('current_password_field'), 'oldPass123');
      await tester.tap(submit);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(find.byType(SuccessPopScreen), findsOneWidget);
      expect(storage.password, 'newPass456');
    });

    testWidgets('change PIN rejects a wrong PIN, then updates it', (
      tester,
    ) async {
      _usePhoneViewport(tester);
      final prefs = await _prefs();
      final storage = _MemorySecureStorage();
      await tester.pumpWidget(_app(prefs, _settingsHome(), storage: storage));
      await tester.pumpAndSettle();

      await _tapVisible(tester, find.text('Security'));
      await _tapVisible(tester, find.text('Change PIN'));

      expect(find.text('Enter PIN'), findsOneWidget);
      final submit = find.byKey(const ValueKey('change_pin_submit_btn'));

      await _enterPinDigits(tester, '9999');
      await tester.tap(submit);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(find.text('Incorrect PIN. Try again.'), findsOneWidget);

      await _enterPinDigits(tester, '1234');
      await tester.tap(submit);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(find.text('Enter new PIN'), findsOneWidget);

      await _enterPinDigits(tester, '4321');
      await tester.tap(submit);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(storage.pin, '4321');
      expect(find.byType(SuccessPopScreen), findsOneWidget);
    });
  });
}
