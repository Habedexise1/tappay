import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/view_state.dart';
import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';

class SettingsController extends ChangeNotifier {
  final SettingsRepository repository;

  SettingsController({required this.repository}) {
    _notifications = repository.loadNotificationPreferences();
    load();
  }

  ViewState<UserProfile> _profileState = const Initial();
  ViewState<UserProfile> get profileState => _profileState;
  UserProfile? get profile => _profileState.dataOrNull;

  ViewState<AccountDetails> _accountState = const Initial();
  ViewState<AccountDetails> get accountState => _accountState;

  ViewState<bool> _phoneUpdateState = const Initial();
  ViewState<bool> get phoneUpdateState => _phoneUpdateState;

  ViewState<bool> _deleteState = const Initial();
  ViewState<bool> get deleteState => _deleteState;

  late NotificationPreferences _notifications;
  NotificationPreferences get notifications => _notifications;

  ({String fullName, String tapTag, String email})? _signUpOverride;

  Future<void> load() async {
    _profileState = const Loading();
    _accountState = const Loading();
    notifyListeners();
    try {
      final profile = await repository.fetchProfile();
      final account = await repository.fetchAccountDetails();
      final merged = _applyOverride(profile);
      _profileState = Success(merged);
      _accountState = Success(
        AccountDetails(
          bankName: account.bankName,
          accountNumber: account.accountNumber,
          accountName: merged.fullName,
        ),
      );
    } catch (e) {
      _profileState = Failure('Could not load your profile. $e');
      _accountState = Failure('Could not load account details. $e');
    }
    notifyListeners();
  }

  void applySignUpDetails({
    required String firstName,
    required String lastName,
    required String tapTag,
    required String email,
  }) {
    final name = [
      firstName.trim(),
      lastName.trim(),
    ].where((p) => p.isNotEmpty).join(' ');
    if (name.isEmpty && tapTag.trim().isEmpty && email.trim().isEmpty) return;

    final next = (
      fullName: name,
      tapTag: tapTag.trim().replaceFirst('@', ''),
      email: email.contains('@') ? email.trim() : '',
    );
    if (next == _signUpOverride) return;
    _signUpOverride = next;

    final current = profile;
    if (current != null) {
      final merged = _applyOverride(current);
      _profileState = Success(merged);
      final account = _accountState.dataOrNull;
      if (account != null) {
        _accountState = Success(
          AccountDetails(
            bankName: account.bankName,
            accountNumber: account.accountNumber,
            accountName: merged.fullName,
          ),
        );
      }
      Future.microtask(notifyListeners);
    }
  }

  UserProfile _applyOverride(UserProfile base) {
    final o = _signUpOverride;
    if (o == null) return base;
    final fullName = o.fullName.isEmpty ? base.fullName : o.fullName;
    return base.copyWith(
      fullName: fullName,
      tapTag: o.tapTag.isEmpty ? base.tapTag : o.tapTag,
      email: o.email.isEmpty ? base.email : o.email,
      referralCode: o.fullName.isEmpty
          ? base.referralCode
          : UserProfile.referralCodeFor(fullName),
    );
  }

  static String? validatePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (!raw.trim().startsWith('+')) {
      return 'Include your country code, e.g. +234';
    }
    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  Future<bool> updatePhoneNumber(String raw) async {
    final error = validatePhone(raw);
    if (error != null) {
      _phoneUpdateState = Failure(error);
      notifyListeners();
      return false;
    }
    if (_phoneUpdateState is Loading) return false;

    _phoneUpdateState = const Loading('Saving...');
    notifyListeners();
    try {
      final updated = await repository.updatePhoneNumber(raw.trim());
      _profileState = Success(_applyOverride(updated));
      _phoneUpdateState = const Success(true);
      notifyListeners();
      return true;
    } catch (e) {
      _phoneUpdateState = Failure('Could not update phone number. $e');
      notifyListeners();
      return false;
    }
  }

  void resetPhoneUpdateState() {
    if (_phoneUpdateState is Initial) return;
    _phoneUpdateState = const Initial();
    notifyListeners();
  }

  Future<void> setNotification(NotificationChannel channel, bool on) async {
    _notifications = _notifications.withChannel(channel, on);
    notifyListeners();
    await repository.saveNotificationPreference(channel, on);
  }

  static String referralLink(String code) => 'https://tappay.app/r/$code';

  String? get referralMessage {
    final code = profile?.referralCode;
    if (code == null) return null;
    return 'Join me on TapPay and earn rewards! Use my referral code $code '
        'or sign up here: ${referralLink(code)}';
  }

  Future<void> shareReferral() async {
    final message = referralMessage;
    if (message == null) return;
    await Share.share(message, subject: 'Join me on TapPay');
  }

  Future<bool> deleteAccount() async {
    if (_deleteState is Loading) return false;
    _deleteState = const Loading('Deleting account...');
    notifyListeners();
    try {
      await repository.deleteAccount();
      _deleteState = const Success(true);
      notifyListeners();
      return true;
    } catch (e) {
      _deleteState = Failure('Could not delete account. $e');
      notifyListeners();
      return false;
    }
  }
}
