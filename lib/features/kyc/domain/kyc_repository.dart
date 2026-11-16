import 'kyc_models.dart';

abstract interface class KycRepository {
  KycStatus loadStatus(KycFlow flow);

  Future<void> saveStatus(KycFlow flow, KycStatus status);

  /// Uploads the application. [onProgress] receives values from 0 to 1.
  /// Returns [KycStatus.inReview] when accepted for review, or
  /// [KycStatus.failed] when automated checks reject it.
  Future<KycStatus> submit(
    KycFlow flow,
    KycApplication application, {
    void Function(double progress)? onProgress,
  });

  /// Completes once the compliance review has a decision.
  Future<KycStatus> awaitReview(KycFlow flow);
}

/// Device file sources for documents (file picker, camera, gallery).
abstract interface class KycMediaSource {
  /// PDF or image document; null when the user cancels.
  Future<KycDocument?> pickDocument();

  Future<KycDocument?> takePhoto();

  Future<KycDocument?> pickPhoto();
}

enum CameraPermission { granted, denied, permanentlyDenied }

abstract interface class CameraPermissionService {
  Future<CameraPermission> status();

  Future<CameraPermission> request();

  /// Opens the OS settings page for the app. Returns false if unavailable.
  Future<bool> openSettings();
}
