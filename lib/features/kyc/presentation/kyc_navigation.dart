import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/kyc_models.dart';
import '../domain/kyc_repository.dart';
import 'kyc_controller.dart';
import 'screens/kyc_address_screen.dart';
import 'screens/kyc_camera_permission_screen.dart';
import 'screens/kyc_employment_screen.dart';
import 'screens/kyc_id_details_screen.dart';
import 'screens/kyc_identity_screen.dart';
import 'screens/kyc_income_screen.dart';
import 'screens/kyc_selfie_capture_screen.dart';
import 'screens/kyc_selfie_intro_screen.dart';
import 'screens/kyc_submission_screen.dart';
import 'screens/kyc_utility_screen.dart';

/// Routing for the KYC journeys. Every KYC route is named `/kyc/...` so the
/// whole journey can be closed in one go.
abstract final class KycNavigator {
  static const _prefix = '/kyc/';

  static Route<T> _route<T>(String name, Widget page) => MaterialPageRoute<T>(
    settings: RouteSettings(name: '$_prefix$name'),
    builder: (_) => page,
  );

  /// Resets the draft and opens the first step of [flow] full screen.
  static Future<void> start(BuildContext context, KycFlow flow) {
    context.read<KycController>().start(flow);
    return Navigator.of(context, rootNavigator: true).push(
      _route(
        '${flow.name}/${flow.steps.first.name}',
        _screenFor(flow.steps.first),
      ),
    );
  }

  /// Moves from [current] to the next step, or to submission after the last.
  static void next(BuildContext context, KycStep current) {
    final flow = context.read<KycController>().flow;
    final step = flow.stepAfter(current);
    if (step == null) {
      Navigator.of(
        context,
      ).push(_route('${flow.name}/submit', const KycSubmissionScreen()));
      return;
    }
    Navigator.of(
      context,
    ).push(_route('${flow.name}/${step.name}', _screenFor(step)));
  }

  /// Opens the selfie camera, showing the permission primer first if needed.
  static Future<void> openSelfieCamera(
    BuildContext context, {
    bool replace = false,
  }) async {
    final permission = await context.read<CameraPermissionService>().status();
    if (!context.mounted) return;
    final route = permission == CameraPermission.granted
        ? _route<void>('selfie/capture', const KycSelfieCaptureScreen())
        : _route<void>('selfie/permission', const KycCameraPermissionScreen());
    final nav = Navigator.of(context);
    replace ? await nav.pushReplacement(route) : await nav.push(route);
  }

  static Future<void> replaceWithCapture(BuildContext context) => Navigator.of(
    context,
  ).pushReplacement(_route('selfie/capture', const KycSelfieCaptureScreen()));

  static void submit(BuildContext context, {bool replace = false}) {
    final flow = context.read<KycController>().flow;
    final route = _route<void>(
      '${flow.name}/submit',
      const KycSubmissionScreen(),
    );
    replace
        ? Navigator.of(context).pushReplacement(route)
        : Navigator.of(context).push(route);
  }

  /// Pops every KYC route, returning to wherever the journey started.
  static void close(BuildContext context) {
    Navigator.of(
      context,
    ).popUntil((route) => !(route.settings.name?.startsWith(_prefix) ?? false));
  }

  static Widget _screenFor(KycStep step) => switch (step) {
    KycStep.employment => const KycEmploymentScreen(),
    KycStep.income => const KycIncomeScreen(),
    KycStep.identity => const KycIdentityScreen(),
    KycStep.idDetails => const KycIdDetailsScreen(),
    KycStep.address => const KycAddressScreen(),
    KycStep.utility => const KycUtilityScreen(),
    KycStep.selfie => const KycSelfieIntroScreen(),
  };
}
