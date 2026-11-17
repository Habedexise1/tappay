import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tappay/app/observers/app_lifecycle_observer.dart';
import 'package:tappay/app/routes/app_routes.dart';
import 'package:tappay/core/errors/exceptions.dart';
import 'package:tappay/core/security/biometrics_service.dart';
import 'package:tappay/core/storage/preferences_service.dart';
import 'package:tappay/core/storage/secure_storage_service.dart';
import 'package:tappay/core/utils/view_state.dart';
import 'package:tappay/features/auth/data/mock_auth_repository.dart';
import 'package:tappay/features/auth/domain/auth_models.dart';
import 'package:tappay/features/auth/domain/auth_repository.dart';
import 'package:tappay/features/auth/presentation/auth_controller.dart';
import 'package:tappay/features/dashboard/data/mock_dashboard_repository.dart';
import 'package:tappay/features/dashboard/domain/dashboard_repository.dart';
import 'package:tappay/features/dashboard/presentation/dashboard_controller.dart';
import 'package:tappay/features/widgets_bridge/home_widget_service.dart';

class _SilentWidgetSync implements HomeWidgetSync {
  @override
  Future<void> syncBalance(String formattedBalance) async {}

  @override
  Future<void> syncLastTransaction({
    required String formattedBalance,
    required String formattedAmount,
    required String merchant,
    required String date,
  }) async {}
}

class _FailingDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSnapshot> loadDashboard() =>
      Future.error(const NetworkException('Dashboard is unreachable'));

  @override
  Future<void> saveBalance(double balance) async {}

  @override
  Future<void> setBalanceMasked(bool masked) async {}
}

class _RejectingPinRepository extends MockAuthRepository {
  _RejectingPinRepository({required super.storage});

  int changePinCalls = 0;

  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    changePinCalls++;
    throw const AuthException('Current PIN is incorrect', 'invalid_pin');
  }
}

void main() {
  late SecureStorageService storage;
  late PreferencesService prefs;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    storage = SecureStorageService();
    prefs = await PreferencesService.init();
  });

  group('MockAuthRepository', () {
    late AuthRepository repository;

    setUp(() => repository = MockAuthRepository(storage: storage));

    test('seeds a default PIN and loads security settings', () async {
      final settings = await repository.loadSecuritySettings();

      expect(settings.isPinSet, isTrue);
      expect(await storage.getPin(), MockAuthRepository.defaultPin);
      expect(await repository.verifyPin('1234'), isTrue);
      expect(await repository.verifyPin('0000'), isFalse);
    });

    test('changePin rejects a wrong current PIN', () async {
      await repository.savePin('2468');

      await expectLater(
        repository.changePin(currentPin: '1111', newPin: '1357'),
        throwsA(isA<AuthException>()),
      );
      expect(await storage.getPin(), '2468');

      await repository.changePin(currentPin: '2468', newPin: '1357');
      expect(await storage.getPin(), '1357');
    });

    test('changePassword rejects a wrong current password', () async {
      await repository.register(password: 'oldPass123');

      await expectLater(
        repository.changePassword(
          currentPassword: 'nope',
          newPassword: 'newPass456',
        ),
        throwsA(isA<AuthException>()),
      );
      expect(await storage.getPassword(), 'oldPass123');
    });

    test('two-factor updates persist the method', () async {
      await repository.updateTwoFactor(
        enabled: true,
        method: TwoFactorMethod.authenticator,
      );

      final settings = await repository.loadSecuritySettings();
      expect(settings.isTwoFactorEnabled, isTrue);
      expect(settings.twoFactorMethod, TwoFactorMethod.authenticator);
    });
  });

  group('AuthController uses the repository boundary', () {
    test('repository errors surface as a failure state', () async {
      final repository = _RejectingPinRepository(storage: storage);
      final controller = AuthController(
        storage: storage,
        biometrics: BiometricsService(),
        repository: repository,
      );
      await pumpEventQueue();

      final ok = await controller.changePin(currentPin: '9999', newPin: '4321');

      expect(ok, isFalse);
      expect(repository.changePinCalls, 1);
      final state = controller.pinActionState as Failure<bool>;
      expect(state.message, 'Current PIN is incorrect');
      controller.dispose();
    });

    test(
      'invalid new PIN is rejected before reaching the repository',
      () async {
        final repository = _RejectingPinRepository(storage: storage);
        final controller = AuthController(
          storage: storage,
          biometrics: BiometricsService(),
          repository: repository,
        );
        await pumpEventQueue();

        final ok = await controller.changePin(currentPin: '1234', newPin: '12');

        expect(ok, isFalse);
        expect(repository.changePinCalls, 0);
        controller.dispose();
      },
    );
  });

  group('Dashboard repository boundary', () {
    test('mock repository seeds data and persists balance changes', () async {
      final repository = MockDashboardRepository(prefs: prefs);

      final snapshot = await repository.loadDashboard();
      expect(snapshot.beneficiaries, isNotEmpty);
      expect(snapshot.notifications.where((n) => !n.isRead), hasLength(2));

      await repository.saveBalance(1250.75);
      await repository.setBalanceMasked(true);
      final reloaded = await repository.loadDashboard();
      expect(reloaded.balance, 1250.75);
      expect(reloaded.isBalanceMasked, isTrue);
    });

    test('load failures surface as a failure balance state', () async {
      final controller = DashboardController(
        prefs: prefs,
        biometrics: BiometricsService(),
        widgetSync: _SilentWidgetSync(),
        repository: _FailingDashboardRepository(),
      );
      await pumpEventQueue();

      final state = controller.balanceState as Failure<double>;
      expect(state.message, 'Dashboard is unreachable');
      controller.dispose();
    });
  });

  group('App layer', () {
    test('lifecycle observer obscures the app outside the foreground', () {
      final observer = AppLifecycleObserver();

      observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
      expect(observer.isObscured.value, isTrue);
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(observer.isObscured.value, isTrue);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(observer.isObscured.value, isFalse);

      final disabled = AppLifecycleObserver(shieldEnabled: false);
      disabled.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(disabled.isObscured.value, isFalse);
    });

    test('route table resolves known routes only', () {
      expect(
        AppRoutes.onGenerateRoute(
          const RouteSettings(name: AppRoutes.qrScanner),
        ),
        isNotNull,
      );
      expect(
        AppRoutes.onGenerateRoute(const RouteSettings(name: '/unknown')),
        isNull,
      );
    });
  });
}
