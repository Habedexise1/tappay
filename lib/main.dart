import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/observers/app_lifecycle_observer.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';
import 'core/security/biometrics_service.dart';
import 'core/security/privacy_shield.dart';
import 'core/storage/preferences_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/dashboard/presentation/dashboard_controller.dart';
import 'features/kyc/data/device_camera_permission_service.dart';
import 'features/kyc/data/device_kyc_media_source.dart';
import 'features/kyc/data/mock_kyc_repository.dart';
import 'features/kyc/domain/kyc_repository.dart';
import 'features/kyc/presentation/kyc_controller.dart';
import 'features/kyc/presentation/selfie_camera.dart';
import 'features/onboarding/presentation/splash_screen.dart';
import 'features/qr_transfer/presentation/qr_transfer_controller.dart';
import 'features/settings/data/mock_settings_repository.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'features/transactions/data/transaction_repository.dart';
import 'features/transactions/presentation/transaction_controller.dart';
import 'features/widgets_bridge/home_widget_service.dart';
import 'features/widgets_bridge/widget_launch_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesService = await PreferencesService.init();
  final secureStorageService = SecureStorageService();
  final biometricsService = BiometricsService();
  final transactionRepository = MockTransactionRepository();

  await HomeWidgetService.initialize();

  runApp(
    TapPayRoot(
      preferencesService: preferencesService,
      secureStorageService: secureStorageService,
      biometricsService: biometricsService,
      transactionRepository: transactionRepository,
    ),
  );
}

class TapPayRoot extends StatelessWidget {
  final PreferencesService preferencesService;
  final SecureStorageService secureStorageService;
  final BiometricsService biometricsService;
  final TransactionRepository transactionRepository;
  final Widget? initialHome;
  final HomeWidgetSync widgetSync;

  final KycRepository? kycRepository;
  final KycMediaSource? kycMediaSource;
  final CameraPermissionService? cameraPermissionService;
  final SelfieCameraFactory? selfieCameraFactory;

  const TapPayRoot({
    super.key,
    required this.preferencesService,
    required this.secureStorageService,
    required this.biometricsService,
    required this.transactionRepository,
    this.initialHome,
    this.widgetSync = const HomeWidgetService(),
    this.kycRepository,
    this.kycMediaSource,
    this.cameraPermissionService,
    this.selfieCameraFactory,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PreferencesService>.value(value: preferencesService),
        Provider<SecureStorageService>.value(value: secureStorageService),
        Provider<BiometricsService>.value(value: biometricsService),
        Provider<TransactionRepository>.value(value: transactionRepository),
        Provider<CameraPermissionService>.value(
          value: cameraPermissionService ?? DeviceCameraPermissionService(),
        ),
        Provider<SelfieCameraFactory>.value(
          value: selfieCameraFactory ?? PluginSelfieCamera.new,
        ),

        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController(preferencesService),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(
            storage: secureStorageService,
            biometrics: biometricsService,
          ),
        ),
        ChangeNotifierProvider<DashboardController>(
          create: (_) => DashboardController(
            prefs: preferencesService,
            biometrics: biometricsService,
            widgetSync: widgetSync,
          ),
        ),
        ChangeNotifierProvider<TransactionController>(
          create: (_) =>
              TransactionController(repository: transactionRepository),
        ),
        ChangeNotifierProvider<KycController>(
          create: (_) => KycController(
            repository:
                kycRepository ?? MockKycRepository(prefs: preferencesService),
            media: kycMediaSource ?? DeviceKycMediaSource(),
          ),
        ),
        ChangeNotifierProxyProvider<AuthController, SettingsController>(
          create: (_) => SettingsController(
            repository: MockSettingsRepository(prefs: preferencesService),
          ),
          update: (_, auth, settings) {
            final draft = auth.signUpDraft;
            return settings!..applySignUpDetails(
              firstName: draft.firstName,
              lastName: draft.lastName,
              tapTag: draft.tapTag,
              email: draft.isPhoneContact ? '' : draft.contactValue,
            );
          },
        ),
        ChangeNotifierProxyProvider2<
          DashboardController,
          TransactionController,
          QrTransferController
        >(
          create: (ctx) => QrTransferController(
            repository: transactionRepository,
            biometrics: biometricsService,
            dashboardController: ctx.read<DashboardController>(),
            transactionController: ctx.read<TransactionController>(),
          ),
          update: (ctx, dashboard, transactions, previous) =>
              previous ??
              QrTransferController(
                repository: transactionRepository,
                biometrics: biometricsService,
                dashboardController: dashboard,
                transactionController: transactions,
              ),
        ),
      ],
      child: TapPayApp(home: initialHome),
    );
  }
}

class TapPayApp extends StatefulWidget {
  final Widget? home;

  const TapPayApp({super.key, this.home});

  @override
  State<TapPayApp> createState() => _TapPayAppState();
}

class _TapPayAppState extends State<TapPayApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final WidgetLaunchService _launchService = WidgetLaunchService();
  final AppLifecycleObserver _lifecycleObserver = AppLifecycleObserver();
  StreamSubscription<Uri>? _linkSubscription;
  DateTime? _lastScannerLaunch;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver.attach();
    _initWidgetDeepLinks();
  }

  Future<void> _initWidgetDeepLinks() async {
    _linkSubscription = _launchService.links.listen(_handleDeepLinkUri);
    _handleDeepLinkUri(await _launchService.start());
  }

  void _handleDeepLinkUri(Uri? uri) {
    if (!WidgetLaunchService.isScannerLink(uri)) return;

    final now = DateTime.now();
    final last = _lastScannerLaunch;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      return;
    }
    _lastScannerLaunch = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.pushNamed(AppRoutes.qrScanner);
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _launchService.dispose();
    _lifecycleObserver.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'TapPay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      builder: (context, child) {
        return AppPrivacyShield(
          obscured: _lifecycleObserver.isObscured,
          child: child ?? const SizedBox.shrink(),
        );
      },
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: widget.home ?? const SplashScreen(),
    );
  }
}
