import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../domain/kyc_repository.dart';
import '../kyc_navigation.dart';
import '../widgets/kyc_widgets.dart';

/// Figma "Camera Permission" frame: explains why the camera is needed
/// before the OS prompt, and recovers from a permanent denial.
class KycCameraPermissionScreen extends StatefulWidget {
  const KycCameraPermissionScreen({super.key});

  @override
  State<KycCameraPermissionScreen> createState() =>
      _KycCameraPermissionScreenState();
}

class _KycCameraPermissionScreenState extends State<KycCameraPermissionScreen>
    with WidgetsBindingObserver {
  CameraPermission? _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Returning from the Settings app may have granted access.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final status = await context.read<CameraPermissionService>().status();
    if (!mounted) return;
    if (status == CameraPermission.granted) {
      KycNavigator.replaceWithCapture(context);
      return;
    }
    setState(() => _status = status);
  }

  Future<void> _allow() async {
    final service = context.read<CameraPermissionService>();
    setState(() => _busy = true);
    if (_status == CameraPermission.permanentlyDenied) {
      await service.openSettings();
      if (mounted) setState(() => _busy = false);
      return;
    }
    final result = await service.request();
    if (!mounted) return;
    setState(() => _busy = false);
    if (result == CameraPermission.granted) {
      KycNavigator.replaceWithCapture(context);
    } else {
      setState(() => _status = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocked = _status == CameraPermission.permanentlyDenied;
    final denied = _status == CameraPermission.denied;

    return SettingsPageScaffold(
      scrollable: false,
      bottomAction: AppButton(
        key: const ValueKey('kyc_camera_allow_btn'),
        text: blocked ? 'Open Settings' : 'Allow',
        isLoading: _busy,
        onPressed: _status == null ? null : _allow,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera,
                size: 127,
                color: AppColors.primaryGreen,
                semanticLabel: 'Camera',
              ),
              const SizedBox(height: 40),
              KycHeading(
                title: 'Camera access',
                textAlign: TextAlign.center,
                subtitle: blocked
                    ? 'Camera access is turned off for TapPay. Open Settings and allow Camera to continue.'
                    : 'Allow TapPay to access your camera while using the app',
              ),
              if (denied) ...[
                const SizedBox(height: 12),
                const KycHelperText(
                  'We need the camera to take your verification selfie.',
                  isError: true,
                ),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
