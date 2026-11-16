class UserProfile {
  final String fullName;
  final String email;
  final String tapTag;
  final String phoneNumber;
  final String referralCode;
  final String? avatarAsset;

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.tapTag,
    required this.phoneNumber,
    required this.referralCode,
    this.avatarAsset,
  });

  String get handle => tapTag.startsWith('@') ? tapTag : '@$tapTag';

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? tapTag,
    String? phoneNumber,
    String? referralCode,
    String? avatarAsset,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      tapTag: tapTag ?? this.tapTag,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      referralCode: referralCode ?? this.referralCode,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }

  static String referralCodeFor(String fullName) {
    final parts = fullName
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .map((p) => p.replaceAll(RegExp(r'[^A-Z]'), ''))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'TAPPAY';
    final first = parts.first;
    final squeezed =
        first[0] + first.substring(1).replaceAll(RegExp(r'[AEIOU]'), '');
    final code = parts.length > 1 ? squeezed + parts.last : first;
    return code.length > 6 ? code.substring(0, 6) : code;
  }
}

class AccountDetails {
  final String bankName;
  final String accountNumber;
  final String accountName;

  const AccountDetails({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });
}

enum NotificationChannel {
  loginEmail('notif_login_email'),
  transactionEmail('notif_tx_email'),
  transactionPush('notif_tx_push');

  final String storageKey;
  const NotificationChannel(this.storageKey);
}

class NotificationPreferences {
  final Map<NotificationChannel, bool> _values;

  const NotificationPreferences(this._values);

  static const allEnabled = NotificationPreferences({
    NotificationChannel.loginEmail: true,
    NotificationChannel.transactionEmail: true,
    NotificationChannel.transactionPush: true,
  });

  bool isEnabled(NotificationChannel channel) => _values[channel] ?? true;

  NotificationPreferences withChannel(NotificationChannel channel, bool on) {
    return NotificationPreferences({..._values, channel: on});
  }
}

enum InfoDocument { privacyPolicy, termsAndConditions, support }

enum BeneficiaryTab { tapTag, bank }
