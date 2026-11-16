import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/view_state.dart';
import '../domain/kyc_models.dart';
import '../domain/kyc_repository.dart';

enum KycMediaOrigin { files, camera, gallery }

class KycController extends ChangeNotifier {
  final KycRepository repository;
  final KycMediaSource media;

  KycController({required this.repository, required this.media}) {
    for (final flow in KycFlow.values) {
      _statuses[flow] = repository.loadStatus(flow);
      // A review interrupted by an app restart resumes on next launch.
      if (_statuses[flow] == KycStatus.inReview) _awaitReview(flow);
    }
  }

  final Map<KycFlow, KycStatus> _statuses = {};
  KycStatus statusFor(KycFlow flow) => _statuses[flow] ?? KycStatus.unverified;

  /// Base-tier (USD KYC) verification, which unlocks NGN/USD/KES wallets.
  bool get isVerified => statusFor(KycFlow.usd) == KycStatus.verified;

  bool isVerifiedFor(KycFlow flow) => statusFor(flow) == KycStatus.verified;

  KycFlow _flow = KycFlow.usd;
  KycFlow get flow => _flow;

  KycApplication _application = const KycApplication();
  KycApplication get application => _application;

  final Map<KycDocumentSlot, ViewState<KycDocument>> _attachStates = {};
  ViewState<KycDocument>? attachState(KycDocumentSlot slot) =>
      _attachStates[slot];

  ViewState<KycStatus> _submission = const Initial();
  ViewState<KycStatus> get submission => _submission;

  double _uploadProgress = 0;
  double get uploadProgress => _uploadProgress;

  /// Starts a fresh journey for [flow].
  void start(KycFlow flow) {
    _flow = flow;
    _application = const KycApplication();
    _attachStates.clear();
    _submission = const Initial();
    _uploadProgress = 0;
    notifyListeners();
  }

  void _update(KycApplication next) {
    _application = next;
    notifyListeners();
  }

  void setEmploymentStatus(EmploymentStatus value) =>
      _update(_application.copyWith(employmentStatus: value));

  void setOccupation(String value) =>
      _update(_application.copyWith(occupation: value));

  void setIncomeBand(IncomeBand value) =>
      _update(_application.copyWith(incomeBand: value));

  void setDateOfBirth(DateTime value) =>
      _update(_application.copyWith(dateOfBirth: value));

  void setMeansOfId(MeansOfId value) =>
      _update(_application.copyWith(meansOfId: value));

  void setIdNumber(String value) =>
      _update(_application.copyWith(idNumber: value));

  /// Accepts raw MM/YY text; incomplete input clears the stored value.
  void setIdIssueDate(String raw) => _update(
    _withDates(
      issue: MonthYear.tryParse(raw),
      expiry: _application.idExpiryDate,
    ),
  );

  void setIdExpiryDate(String raw) => _update(
    _withDates(
      issue: _application.idIssueDate,
      expiry: MonthYear.tryParse(raw),
    ),
  );

  /// copyWith cannot clear a field, so dates are rebuilt explicitly.
  KycApplication _withDates({
    required MonthYear? issue,
    required MonthYear? expiry,
  }) {
    final app = _application;
    return KycApplication(
      employmentStatus: app.employmentStatus,
      occupation: app.occupation,
      incomeBand: app.incomeBand,
      bankStatement: app.bankStatement,
      dateOfBirth: app.dateOfBirth,
      meansOfId: app.meansOfId,
      idFront: app.idFront,
      idNumber: app.idNumber,
      idIssueDate: issue,
      idExpiryDate: expiry,
      address: app.address,
      utilityBill: app.utilityBill,
      selfie: app.selfie,
    );
  }

  void setAddress({
    String? country,
    String? state,
    String? city,
    String? street,
  }) => _update(
    _application.copyWith(
      address: _application.address.copyWith(
        country: country,
        state: state,
        city: city,
        street: street,
      ),
    ),
  );

  /// Why [step] cannot continue yet, or null when it is complete.
  String? blockerFor(KycStep step) => KycRules.validateStep(step, _application);

  bool canContinue(KycStep step) => blockerFor(step) == null;

  Future<void> attach(KycDocumentSlot slot, KycMediaOrigin origin) async {
    if (_attachStates[slot] is Loading) return;
    _attachStates[slot] = const Loading();
    notifyListeners();
    try {
      final doc = await switch (origin) {
        KycMediaOrigin.files => media.pickDocument(),
        KycMediaOrigin.camera => media.takePhoto(),
        KycMediaOrigin.gallery => media.pickPhoto(),
      };
      if (doc == null) {
        // Cancelled: keep whatever was attached before.
        final existing = _application.document(slot);
        _attachStates[slot] = existing == null
            ? const Initial()
            : Success(existing);
      } else if (doc.sizeBytes > KycDocument.maxSizeBytes) {
        _attachStates[slot] = const Failure('File is larger than 10 MB');
      } else {
        _application = _application.withDocument(slot, doc);
        _attachStates[slot] = Success(doc);
      }
    } catch (e) {
      _attachStates[slot] = Failure('Could not open file: $e');
    }
    notifyListeners();
  }

  void removeDocument(KycDocumentSlot slot) {
    _application = _application.withDocument(slot, null);
    _attachStates.remove(slot);
    notifyListeners();
  }

  void setSelfie(KycDocument selfie) {
    _application = _application.withDocument(KycDocumentSlot.selfie, selfie);
    notifyListeners();
  }

  /// Uploads the current application once; repeated calls while an upload
  /// is running return the same result instead of submitting twice.
  Future<KycStatus>? _inFlight;

  Future<KycStatus> submit() {
    return _inFlight ??= _submit().whenComplete(() => _inFlight = null);
  }

  Future<KycStatus> _submit() async {
    final flow = _flow;
    final blocker = flow.steps
        .map(blockerFor)
        .firstWhere((b) => b != null, orElse: () => null);
    if (blocker != null) {
      _submission = Failure(blocker);
      notifyListeners();
      return KycStatus.unverified;
    }

    _uploadProgress = 0;
    _submission = const Loading('Uploading information please wait...');
    notifyListeners();

    try {
      final status = await repository.submit(
        flow,
        _application,
        onProgress: (p) {
          _uploadProgress = p;
          notifyListeners();
        },
      );
      await _setStatus(flow, status);
      _submission = status == KycStatus.failed
          ? const Failure(
              'Please try again. Ensure the photo is clear and taken in a bright environment.',
            )
          : Success(status);
      if (status == KycStatus.inReview) _awaitReview(flow);
      notifyListeners();
      return status;
    } catch (e) {
      _submission = Failure('Upload failed. Check your connection. $e');
      notifyListeners();
      return KycStatus.unverified;
    }
  }

  /// Clears a failed selfie so the user can retake it.
  void retrySelfie() {
    _application = _application.withDocument(KycDocumentSlot.selfie, null);
    _submission = const Initial();
    _uploadProgress = 0;
    notifyListeners();
  }

  Future<void> _setStatus(KycFlow flow, KycStatus status) async {
    _statuses[flow] = status;
    notifyListeners();
    await repository.saveStatus(flow, status);
  }

  void _awaitReview(KycFlow flow) {
    unawaited(
      repository.awaitReview(flow).then((status) {
        if (_disposed) return;
        _setStatus(flow, status);
      }),
    );
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
