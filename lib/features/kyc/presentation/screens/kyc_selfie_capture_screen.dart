import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../kyc_controller.dart';
import '../kyc_navigation.dart';
import '../selfie_camera.dart';

/// Figma "Take a selfie" frame: live front camera inside an oval guide,
/// lighting feedback and a shutter button.
class KycSelfieCaptureScreen extends StatefulWidget {
  const KycSelfieCaptureScreen({super.key});

  @override
  State<KycSelfieCaptureScreen> createState() => _KycSelfieCaptureScreenState();
}

class _KycSelfieCaptureScreenState extends State<KycSelfieCaptureScreen> {
  late final SelfieCamera _camera;
  bool _capturing = false;
  String? _captureError;

  @override
  void initState() {
    super.initState();
    _camera = context.read<SelfieCameraFactory>()();
    _camera.initialize();
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_capturing || !_camera.isReady) return;
    setState(() {
      _capturing = true;
      _captureError = null;
    });
    HapticFeedback.mediumImpact();
    try {
      final selfie = await _camera.capture();
      if (!mounted) return;
      context.read<KycController>().setSelfie(selfie);
      KycNavigator.submit(context, replace: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _capturing = false;
        _captureError = 'Could not take the photo. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);

    return Scaffold(
      backgroundColor: palette.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SettingsBackButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Take a selfie',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: palette.heading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please fit your face in the oval frame and take the selfie',
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 16,
                      height: 1.4,
                      color: palette.body,
                    ),
                  ),
                  const SizedBox(height: 19),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _camera,
                      builder: (context, _) => _OvalViewfinder(
                        camera: _camera,
                        capturing: _capturing,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_captureError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Center(
                        child: Text(
                          _captureError!,
                          style: const TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 12,
                            color: AppColors.accentRed,
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: ListenableBuilder(
                      listenable: _camera,
                      builder: (context, _) => _ShutterButton(
                        enabled: _camera.isReady && !_capturing,
                        busy: _capturing,
                        onPressed: _capture,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OvalViewfinder extends StatelessWidget {
  final SelfieCamera camera;
  final bool capturing;

  const _OvalViewfinder({required this.camera, required this.capturing});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final (hint, hintIsWarning) = switch (camera) {
      SelfieCamera(error: final String e) => (e, true),
      SelfieCamera(isReady: false) => ('Starting camera…', false),
      _ when capturing => ('Hold still…', false),
      SelfieCamera(lighting: SelfieLighting.tooDark) => (
        'Too dark. Move somewhere brighter',
        true,
      ),
      SelfieCamera(lighting: SelfieLighting.tooBright) => (
        'Too bright. Avoid direct light',
        true,
      ),
      _ => ('Position your face in the oval', false),
    };
    final ringColor = hintIsWarning
        ? AppColors.primaryYellow
        : AppColors.primaryGreen;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Figma oval is 335 × 474; keep that ratio inside the free space.
        const ratio = 335 / 474;
        var height = constraints.maxHeight;
        var width = height * ratio;
        if (width > constraints.maxWidth) {
          width = constraints.maxWidth;
          height = width / ratio;
        }

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipOval(
                  child: ColoredBox(
                    color: palette.isDark ? Colors.black : AppColors.slate200,
                    child: camera.isReady
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: 300,
                              height: 300 / camera.previewAspectRatio,
                              child: camera.buildPreview(),
                            ),
                          )
                        : Center(
                            child: camera.error == null
                                ? const CircularProgressIndicator(
                                    color: AppColors.primaryGreen,
                                  )
                                : Icon(
                                    Icons.no_photography_outlined,
                                    size: 48,
                                    color: palette.body,
                                  ),
                          ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: ShapeDecoration(
                    shape: OvalBorder(
                      side: BorderSide(color: ringColor, width: 3),
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: height * 0.08,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        key: ValueKey(hint),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          hint,
                          key: const ValueKey('kyc_selfie_hint'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: hintIsWarning
                                ? AppColors.primaryYellow
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;

  const _ShutterButton({
    required this.enabled,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Take selfie',
      child: Opacity(
        opacity: enabled || busy ? 1 : 0.5,
        child: Material(
          color: AppColors.primaryGreen,
          shape: const CircleBorder(),
          child: InkWell(
            key: const ValueKey('kyc_shutter_btn'),
            customBorder: const CircleBorder(),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              width: 64,
              height: 64,
              child: busy
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.lightTextPrimary,
                      ),
                    )
                  : const Icon(
                      Icons.photo_camera_rounded,
                      size: 28,
                      color: AppColors.lightTextPrimary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
