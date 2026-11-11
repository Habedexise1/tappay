import 'package:flutter/foundation.dart';
import '../../../core/utils/view_state.dart';
import '../domain/kyc_models.dart';

/// Provider controller managing KYC onboarding flows:
/// Employment info, ID capture, and Selfie face-alignment verification.
class KycController extends ChangeNotifier {
  KycProfile _profile = const KycProfile();
  KycProfile get profile => _profile;

  ViewState<bool> _submissionState = const Initial();
  ViewState<bool> get submissionState => _submissionState;

  bool _isBankStatementUploaded = false;
  bool get isBankStatementUploaded => _isBankStatementUploaded;

  bool _isIdFrontUploaded = false;
  bool get isIdFrontUploaded => _isIdFrontUploaded;

  bool _isSelfieCaptured = false;
  bool get isSelfieCaptured => _isSelfieCaptured;

  void updateEmploymentStatus(EmploymentStatus status) {
    _profile = _profile.copyWith(employmentStatus: status);
    notifyListeners();
  }

  void updateIncomeBand(IncomeBand band) {
    _profile = _profile.copyWith(incomeBand: band);
    notifyListeners();
  }

  void simulateUploadBankStatement() {
    _isBankStatementUploaded = true;
    _profile = _profile.copyWith(bankStatementPath: 'bank_statement_2026.pdf');
    notifyListeners();
  }

  void updateIdType(IdType type) {
    _profile = _profile.copyWith(idType: type);
    notifyListeners();
  }

  void updateIdNumber(String number) {
    _profile = _profile.copyWith(idNumber: number);
    notifyListeners();
  }

  void updateDateOfBirth(DateTime dob) {
    _profile = _profile.copyWith(dateOfBirth: dob);
    notifyListeners();
  }

  void simulateUploadIdFront() {
    _isIdFrontUploaded = true;
    _profile = _profile.copyWith(idFrontPath: 'id_front_scan.jpg');
    notifyListeners();
  }

  void captureSelfie() {
    _isSelfieCaptured = true;
    _profile = _profile.copyWith(selfiePhotoPath: 'selfie_verified.jpg');
    notifyListeners();
  }

  Future<bool> submitVerification() async {
    _submissionState = const Loading('Verifying credentials with automated KYC engine...');
    notifyListeners();

    // 1.5s simulated network processing
    await Future.delayed(const Duration(milliseconds: 1500));

    _profile = _profile.copyWith(isVerified: true);
    _submissionState = const Success(true);
    notifyListeners();
    return true;
  }

  void reset() {
    _profile = const KycProfile();
    _isBankStatementUploaded = false;
    _isIdFrontUploaded = false;
    _isSelfieCaptured = false;
    _submissionState = const Initial();
    notifyListeners();
  }
}

