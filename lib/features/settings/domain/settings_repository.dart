import 'settings_models.dart';

abstract interface class SettingsRepository {
  Future<UserProfile> fetchProfile();

  Future<UserProfile> updatePhoneNumber(String phoneNumber);

  Future<AccountDetails> fetchAccountDetails();

  NotificationPreferences loadNotificationPreferences();

  Future<void> saveNotificationPreference(
    NotificationChannel channel,
    bool enabled,
  );

  Future<void> deleteAccount();
}
