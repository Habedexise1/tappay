import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Centralized route paths and route name constants for TapPay.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String pinVerification = '/auth/pin';
  static const String changePin = '/auth/pin/change';
  static const String otpVerification = '/auth/otp';
  static const String twoFactorSetup = '/auth/2fa';

  static const String dashboard = '/dashboard';
  static const String notifications = '/notifications';

  static const String kycEmployment = '/kyc/employment';
  static const String kycIdentity = '/kyc/identity';
  static const String kycSelfie = '/kyc/selfie';

  static const String qrScanner = '/transfer/qr-scanner';
  static const String qrGenerator = '/transfer/qr-generator';
  static const String paymentTransfer = '/transfer/pay';
  static const String transactionResult = '/transfer/result';

  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/detail';
  static const String receipt = '/transactions/receipt';
}

/// Global GoRouter instance supporting standard navigation and deep links:
/// e.g. "tappay://qr_scanner" directly launches into AppRoutes.qrScanner.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNav');

  static GoRouter createRouter({required Widget initialHomeWidget}) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.home,
      debugLogDiagnostics: false,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => initialHomeWidget,
        ),
        // Deep-link alias for native home widget tap
        GoRoute(
          path: '/qr_scanner',
          redirect: (context, state) => AppRoutes.qrScanner,
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri.toString()}'),
        ),
      ),
    );
  }
}

