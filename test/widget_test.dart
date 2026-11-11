import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tappay/app/theme/theme_controller.dart';
import 'package:tappay/core/security/biometrics_service.dart';
import 'package:tappay/core/storage/preferences_service.dart';
import 'package:tappay/core/storage/secure_storage_service.dart';
import 'package:tappay/features/onboarding/presentation/splash_screen.dart';
import 'package:tappay/features/onboarding/presentation/welcome_screen.dart';
import 'package:tappay/features/transactions/data/transaction_repository.dart';
import 'package:tappay/main.dart';

void main() {
  testWidgets('SplashScreen renders correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesService.init();

    await tester.pumpWidget(
      TapPayRoot(
        preferencesService: prefs,
        secureStorageService: SecureStorageService(),
        biometricsService: BiometricsService(),
        transactionRepository: MockTransactionRepository(),
        initialHome: const SplashScreen(enableTimer: false, enableAnimations: false),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('tappay.'), findsWidgets);
  });

  testWidgets('WelcomeScreen renders all 3 slides and toggles theme', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesService.init();

    await tester.pumpWidget(
      TapPayRoot(
        preferencesService: prefs,
        secureStorageService: SecureStorageService(),
        biometricsService: BiometricsService(),
        transactionRepository: MockTransactionRepository(),
        initialHome: const WelcomeScreen(enableAnimations: false),
      ),
    );
    await tester.pumpAndSettle();

    // Verify slide 1 headline
    expect(find.textContaining('Not just'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Verify initial Light mode
    final themeController = tester.element(find.byType(TapPayApp)).read<ThemeController>();
    expect(themeController.isDarkMode, isFalse);

    // Toggle to Dark mode
    final themeToggleBtn = find.byTooltip('Switch to Dark Mode');
    expect(themeToggleBtn, findsOneWidget);
    await tester.tap(themeToggleBtn);
    await tester.pumpAndSettle();

    expect(themeController.isDarkMode, isTrue);

    // Swipe to Slide 2
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    // Verify slide 2 headline
    expect(find.textContaining('Custom'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    // Swipe to Slide 3 (Send, receive and swap money)
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    // Verify slide 3 headline
    expect(find.textContaining('swap money'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
