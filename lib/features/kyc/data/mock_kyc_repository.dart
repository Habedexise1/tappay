import '../../../core/storage/preferences_service.dart';
import '../domain/kyc_models.dart';
import '../domain/kyc_repository.dart';

/// Simulated KYC backend: upload progress, automated photo check and a
/// delayed compliance review. Statuses persist per flow.
class MockKycRepository implements KycRepository {
  final PreferencesService prefs;
  final Duration uploadDuration;
  final Duration reviewDuration;

  MockKycRepository({
    required this.prefs,
    this.uploadDuration = const Duration(milliseconds: 1800),
    this.reviewDuration = const Duration(seconds: 4),
  });

  /// Selfies smaller than this are treated as too dark/unclear, the case the
  /// Figma "Verification failed" frame describes.
  static const minSelfieBytes = 15 * 1024;

  String _key(KycFlow flow) => 'kyc_status_${flow.name}';

  @override
  KycStatus loadStatus(KycFlow flow) {
    final stored = prefs.getString(_key(flow));
    return KycStatus.values.firstWhere(
      (s) => s.name == stored,
      orElse: () => KycStatus.unverified,
    );
  }

  @override
  Future<void> saveStatus(KycFlow flow, KycStatus status) =>
      prefs.setString(_key(flow), status.name);

  @override
  Future<KycStatus> submit(
    KycFlow flow,
    KycApplication application, {
    void Function(double progress)? onProgress,
  }) async {
    const ticks = 12;
    for (var i = 1; i <= ticks; i++) {
      await Future<void>.delayed(uploadDuration ~/ ticks);
      onProgress?.call(i / ticks);
    }

    final selfie = application.selfie;
    if (flow.steps.contains(KycStep.selfie) &&
        (selfie == null || selfie.sizeBytes < minSelfieBytes)) {
      return KycStatus.failed;
    }
    return KycStatus.inReview;
  }

  @override
  Future<KycStatus> awaitReview(KycFlow flow) async {
    await Future<void>.delayed(reviewDuration);
    return KycStatus.verified;
  }
}
