import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tappay/core/security/biometrics_service.dart';
import 'package:tappay/core/storage/preferences_service.dart';
import 'package:tappay/core/storage/secure_storage_service.dart';
import 'package:tappay/core/widgets/flag_icon.dart';
import 'package:tappay/features/auth/presentation/screens/login_screen.dart';
import 'package:tappay/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:tappay/features/auth/presentation/screens/signup/creating_account_screen.dart';
import 'package:tappay/features/auth/presentation/screens/signup/signup_address_screen.dart';
import 'package:tappay/features/auth/presentation/screens/signup/signup_bvn_screen.dart';
import 'package:tappay/features/auth/presentation/screens/signup/signup_contact_screen.dart';
import 'package:tappay/features/auth/presentation/screens/signup/signup_name_screen.dart';
import 'package:tappay/features/auth/presentation/screens/signup/signup_password_screen.dart';
import 'package:tappay/features/auth/presentation/screens/signup/signup_tag_screen.dart';
import 'package:tappay/features/onboarding/presentation/welcome_screen.dart';
import 'package:tappay/features/transactions/data/transaction_repository.dart';
import 'package:tappay/main.dart';

Future<PreferencesService> _initMockPrefs({bool isDark = false}) async {
  SharedPreferences.setMockInitialValues({
    'theme_mode': isDark ? 'dark' : 'light',
  });
  return PreferencesService.init();
}

Widget _wrapWithApp(PreferencesService prefs, Widget home) {
  return TapPayRoot(
    preferencesService: prefs,
    secureStorageService: SecureStorageService(),
    biometricsService: BiometricsService(),
    transactionRepository: MockTransactionRepository(),
    initialHome: home,
  );
}

void main() {
  testWidgets('WelcomeScreen routes Get Started to SignUpContactScreen', (
    WidgetTester tester,
  ) async {
    final prefs = await _initMockPrefs();
    await tester.pumpWidget(
      _wrapWithApp(prefs, const WelcomeScreen(enableAnimations: false)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpContactScreen), findsOneWidget);
    expect(find.text('Enter your email\naddress'), findsOneWidget);

    await tester.tap(find.text('Use phone instead'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your phone\nnumber'), findsOneWidget);
    expect(find.byType(FlagIcon), findsOneWidget);

    await tester.tap(find.byType(FlagIcon));
    await tester.pumpAndSettle();

    expect(find.text('Select country code'), findsOneWidget);
    expect(find.text('Nigeria (+234)'), findsOneWidget);
    expect(find.text('United States (+1)'), findsOneWidget);
  });

  testWidgets('WelcomeScreen routes Login to LoginScreen in Dark mode', (
    WidgetTester tester,
  ) async {
    final prefs = await _initMockPrefs(isDark: true);
    await tester.pumpWidget(
      _wrapWithApp(prefs, const WelcomeScreen(enableAnimations: false)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Log into your account'), findsOneWidget);
    expect(find.text('Use biometrics'), findsOneWidget);

    await tester.tap(find.text('Forgot password? Reset'));
    await tester.pumpAndSettle();

    expect(find.byType(ResetPasswordScreen), findsOneWidget);
    expect(find.text('Reset password'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'johndoe@example.com');
    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Sent'), findsOneWidget);
    expect(find.text('Enter OTP'), findsOneWidget);
  });

  testWidgets(
    'Sign-up step screens 1/4 to 4/4, Password, and CreatingAccount render cleanly',
    (WidgetTester tester) async {
      final prefs = await _initMockPrefs();

      await tester.pumpWidget(_wrapWithApp(prefs, const SignUpNameScreen()));
      await tester.pumpAndSettle();
      expect(find.text('1/4'), findsOneWidget);
      expect(find.text('What’s your name'), findsOneWidget);

      await tester.pumpWidget(_wrapWithApp(prefs, const SignUpAddressScreen()));
      await tester.pumpAndSettle();
      expect(find.text('2/4'), findsOneWidget);
      expect(find.text('Your home address'), findsOneWidget);
      await tester.tap(find.text('Select country'));
      await tester.pumpAndSettle();
      expect(find.text('Nigeria'), findsOneWidget);
      await tester.tap(find.text('Nigeria'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_wrapWithApp(prefs, const SignUpTagScreen()));
      await tester.pumpAndSettle();
      expect(find.text('3/4'), findsOneWidget);
      expect(find.text('Create a TapTag'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '@tappaydev');
      await tester.pump();
      expect(find.text('TapPay.app/tappaydev'), findsOneWidget);

      await tester.pumpWidget(_wrapWithApp(prefs, const SignUpBvnScreen()));
      await tester.pumpAndSettle();
      expect(find.text('4/4'), findsOneWidget);
      expect(find.text('What’s your BVN'), findsOneWidget);

      await tester.pumpWidget(
        _wrapWithApp(prefs, const SignUpPasswordScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Create a password'), findsOneWidget);

      await tester.pumpWidget(
        _wrapWithApp(
          prefs,
          const CreatingAccountScreen(enableAutoRedirect: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Creating your\naccount'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    },
  );
}
