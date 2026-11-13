import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';

import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';
import 'core/security/biometrics_service.dart';
import 'core/security/privacy_shield.dart';
import 'core/storage/preferences_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/widgets/app_button.dart';
import 'core/widgets/app_card.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/dashboard/presentation/dashboard_controller.dart';
import 'features/kyc/presentation/kyc_controller.dart';
import 'features/onboarding/presentation/splash_screen.dart';
import 'features/qr_transfer/presentation/qr_transfer_controller.dart';
import 'features/qr_transfer/presentation/screens/qr_scanner_screen.dart';
import 'features/transactions/data/transaction_repository.dart';
import 'features/transactions/presentation/transaction_controller.dart';
import 'features/widgets_bridge/home_widget_service.dart';

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

  const TapPayRoot({
    super.key,
    required this.preferencesService,
    required this.secureStorageService,
    required this.biometricsService,
    required this.transactionRepository,
    this.initialHome,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PreferencesService>.value(value: preferencesService),
        Provider<SecureStorageService>.value(value: secureStorageService),
        Provider<BiometricsService>.value(value: biometricsService),
        Provider<TransactionRepository>.value(value: transactionRepository),

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
          ),
        ),
        ChangeNotifierProvider<TransactionController>(
          create: (_) =>
              TransactionController(repository: transactionRepository),
        ),
        ChangeNotifierProvider<KycController>(create: (_) => KycController()),
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
  StreamSubscription<Uri?>? _widgetClickSubscription;

  @override
  void initState() {
    super.initState();
    _initWidgetDeepLinks();
  }

  Future<void> _initWidgetDeepLinks() async {
    try {
      final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      _handleDeepLinkUri(initialUri);
      _widgetClickSubscription = HomeWidget.widgetClicked.listen(
        _handleDeepLinkUri,
      );
    } catch (_) {}
  }

  void _handleDeepLinkUri(Uri? uri) {
    if (uri == null) return;
    if (uri.scheme == 'tappay' && uri.host == 'qr_scanner') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const QrScannerScreen()),
        );
      });
    }
  }

  @override
  void dispose() {
    _widgetClickSubscription?.cancel();
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
        return AppPrivacyShield(child: child ?? const SizedBox.shrink());
      },
      home: widget.home ?? const SplashScreen(),
    );
  }
}

class ArchitectureReadyScreen extends StatelessWidget {
  const ArchitectureReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TapPay Setup Ready'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => themeController.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Architecture & Provider Ready',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Clean layer separation, Provider controllers, Theme management, and security wrappers are configured. Ready for your designs!',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusRow(
                          context,
                          'State Management',
                          'Provider (MultiProvider)',
                        ),
                        const Divider(height: 24),
                        _buildStatusRow(
                          context,
                          'Theme Mode',
                          isDark ? 'Dark Mode' : 'Light Mode',
                        ),
                        const Divider(height: 24),
                        _buildStatusRow(
                          context,
                          'Privacy Shield',
                          'Active (Task Switcher)',
                        ),
                        const Divider(height: 24),
                        _buildStatusRow(
                          context,
                          'Security & Biometrics',
                          'local_auth & SecureStorage',
                        ),
                        const Divider(height: 24),
                        _buildStatusRow(
                          context,
                          'Native Widgets',
                          'HomeWidget IPC Bridge',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: isDark
                        ? 'Switch to Light Theme'
                        : 'Switch to Dark Theme',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => themeController.toggleTheme(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
