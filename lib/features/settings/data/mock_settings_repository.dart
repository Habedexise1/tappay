import '../../../app/config/app_assets.dart';
import '../../../core/storage/preferences_service.dart';
import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';

class MockSettingsRepository implements SettingsRepository {
  final PreferencesService prefs;
  final Duration latency;

  MockSettingsRepository({
    required this.prefs,
    this.latency = const Duration(milliseconds: 400),
  });

  static const _phoneKey = 'profile_phone';

  static const UserProfile _seed = UserProfile(
    fullName: 'John Doe',
    email: 'johndoe@example.com',
    tapTag: 'johndoe',
    phoneNumber: '+234 8123456789',
    referralCode: 'JHNDOE',
    avatarAsset: AppAssets.profileAvatar,
  );

  @override
  Future<UserProfile> fetchProfile() async {
    await Future<void>.delayed(latency);
    final phone = prefs.getString(_phoneKey);
    return phone == null ? _seed : _seed.copyWith(phoneNumber: phone);
  }

  @override
  Future<UserProfile> updatePhoneNumber(String phoneNumber) async {
    await Future<void>.delayed(latency);
    await prefs.setString(_phoneKey, phoneNumber);
    return (await fetchProfile()).copyWith(phoneNumber: phoneNumber);
  }

  @override
  Future<AccountDetails> fetchAccountDetails() async {
    await Future<void>.delayed(latency);
    return const AccountDetails(
      bankName: 'Providus',
      accountNumber: '1234567890',
      accountName: 'John Doe',
    );
  }

  @override
  NotificationPreferences loadNotificationPreferences() {
    var result = NotificationPreferences.allEnabled;
    for (final channel in NotificationChannel.values) {
      result = result.withChannel(
        channel,
        prefs.getFlag(channel.storageKey, defaultValue: true),
      );
    }
    return result;
  }

  @override
  Future<void> saveNotificationPreference(
    NotificationChannel channel,
    bool enabled,
  ) {
    return prefs.setFlag(channel.storageKey, enabled);
  }

  @override
  Future<void> deleteAccount() async {
    await Future<void>.delayed(latency);
  }
}
