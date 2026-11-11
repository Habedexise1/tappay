import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tappay/app/theme/theme_controller.dart';
import 'package:tappay/core/security/biometrics_service.dart';
import 'package:tappay/core/storage/preferences_service.dart';
import 'package:tappay/core/storage/secure_storage_service.dart';
import 'package:tappay/features/transactions/data/transaction_repository.dart';
import 'package:tappay/main.dart';

void main() {
  testWidgets('TapPayRoot smoke test and theme toggle', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesService.init();

    await tester.pumpWidget(
      TapPayRoot(
        preferencesService: prefs,
        secureStorageService: SecureStorageService(),
        biometricsService: BiometricsService(),
        transactionRepository: MockTransactionRepository(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial setup screen renders
    expect(find.text('TapPay Setup Ready'), findsOneWidget);
    expect(find.text('Architecture & Provider Ready'), findsOneWidget);

    // Verify theme toggle works
    final themeController = tester.element(find.byType(TapPayApp)).read<ThemeController>();
    expect(themeController.isDarkMode, isFalse);

    await themeController.toggleTheme();
    await tester.pumpAndSettle();
    expect(themeController.isDarkMode, isTrue);
  });
}
