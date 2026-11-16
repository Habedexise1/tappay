import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../domain/kyc_models.dart';

/// Live lighting feedback derived from preview frames.
enum SelfieLighting { unknown, tooDark, good, tooBright }

/// Front-camera session used by the selfie screen. Abstracted so widget
/// tests can run without the camera plugin.
abstract class SelfieCamera extends ChangeNotifier {
  bool get isReady;
  String? get error;
  SelfieLighting get lighting;

  /// Portrait preview width / height, used to fill the oval without
  /// distortion.
  double get previewAspectRatio;

  Future<void> initialize();

  Widget buildPreview();

  Future<KycDocument> capture();
}

typedef SelfieCameraFactory = SelfieCamera Function();

/// [SelfieCamera] backed by the `camera` plugin. Samples preview frames to
/// warn when the scene is too dark or too bright for a clear selfie.
class PluginSelfieCamera extends SelfieCamera {
  CameraController? _controller;
  bool _ready = false;
  String? _error;
  SelfieLighting _lighting = SelfieLighting.unknown;
  DateTime _lastSample = DateTime.fromMillisecondsSinceEpoch(0);
  bool _streaming = false;
  bool _disposed = false;

  @override
  bool get isReady => _ready;
  @override
  String? get error => _error;
  @override
  SelfieLighting get lighting => _lighting;
  @override
  double get previewAspectRatio {
    final controller = _controller;
    if (controller == null || !_ready) return 3 / 4;
    // The plugin reports landscape width / height.
    return 1 / controller.value.aspectRatio;
  }

  @override
  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _fail('No camera found on this device');
        return;
      }
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.iOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );
      _controller = controller;
      await controller.initialize();
      if (_disposed) return;
      _ready = true;
      notifyListeners();
      await _startLightingStream();
    } on CameraException catch (e) {
      _fail(switch (e.code) {
        'CameraAccessDenied' ||
        'CameraAccessDeniedWithoutPrompt' ||
        'CameraAccessRestricted' => 'Camera access was denied',
        _ => 'Could not start the camera (${e.code})',
      });
    }
  }

  void _fail(String message) {
    _error = message;
    if (!_disposed) notifyListeners();
  }

  Future<void> _startLightingStream() async {
    final controller = _controller;
    if (controller == null || _streaming) return;
    try {
      await controller.startImageStream(_onFrame);
      _streaming = true;
    } catch (_) {
      // Lighting hints are best-effort; capture still works without them.
    }
  }

  void _onFrame(CameraImage image) {
    final now = DateTime.now();
    if (now.difference(_lastSample) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastSample = now;
    final luma = _averageLuma(image);
    final next = luma < 55
        ? SelfieLighting.tooDark
        : luma > 225
        ? SelfieLighting.tooBright
        : SelfieLighting.good;
    if (next != _lighting && !_disposed) {
      _lighting = next;
      notifyListeners();
    }
  }

  /// Mean brightness (0–255) from a sparse sample of the frame.
  static double _averageLuma(CameraImage image) {
    final plane = image.planes.first;
    final Uint8List bytes = plane.bytes;
    final isBgra = image.format.group == ImageFormatGroup.bgra8888;
    final stride = isBgra ? 4 : 1;
    final step = (bytes.length ~/ (2000 * stride)).clamp(1, 1 << 20) * stride;
    var sum = 0.0;
    var count = 0;
    for (var i = 0; i + 2 < bytes.length; i += step) {
      sum += isBgra
          ? 0.114 * bytes[i] + 0.587 * bytes[i + 1] + 0.299 * bytes[i + 2]
          : bytes[i];
      count++;
    }
    return count == 0 ? 0 : sum / count;
  }

  @override
  Widget buildPreview() {
    final controller = _controller;
    if (controller == null || !_ready) return const SizedBox.shrink();
    return CameraPreview(controller);
  }

  @override
  Future<KycDocument> capture() async {
    final controller = _controller;
    if (controller == null || !_ready) {
      throw StateError('Camera is not ready');
    }
    if (_streaming) {
      await controller.stopImageStream();
      _streaming = false;
    }
    final file = await controller.takePicture();
    unawaited(_startLightingStream());
    return KycDocument(
      name: file.name,
      path: file.path,
      sizeBytes: await file.length(),
      isImage: true,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      if (_streaming) {
        controller.stopImageStream().catchError((_) {});
      }
      controller.dispose();
    }
    super.dispose();
  }
}
