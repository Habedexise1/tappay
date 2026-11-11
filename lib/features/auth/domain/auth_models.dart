/// Two-factor authentication options.
enum TwoFactorMethod {
  sms('SMS Authentication', 'Receive security codes via your mobile number', 'SMS'),
  authenticator('Authenticator App', 'Use Google Authenticator or Authy for TOTP', 'TOTP'),
  email('Email Verification', 'Receive one-time passcodes via your registered email', 'Email');

  final String title;
  final String description;
  final String badge;
  const TwoFactorMethod(this.title, this.description, this.badge);
}

/// Representation of user security status.
class SecuritySettings {
  final bool isPinSet;
  final bool isBiometricsEnabled;
  final bool isTwoFactorEnabled;
  final TwoFactorMethod twoFactorMethod;

  const SecuritySettings({
    required this.isPinSet,
    required this.isBiometricsEnabled,
    required this.isTwoFactorEnabled,
    required this.twoFactorMethod,
  });

  SecuritySettings copyWith({
    bool? isPinSet,
    bool? isBiometricsEnabled,
    bool? isTwoFactorEnabled,
    TwoFactorMethod? twoFactorMethod,
  }) {
    return SecuritySettings(
      isPinSet: isPinSet ?? this.isPinSet,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      twoFactorMethod: twoFactorMethod ?? this.twoFactorMethod,
    );
  }
}

