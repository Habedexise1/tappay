import '../../../../app/config/app_assets.dart';

enum TwoFactorMethod {
  sms(
    'SMS Authentication',
    'Receive security codes via your mobile number',
    'SMS',
  ),
  authenticator(
    'Authenticator App',
    'Use Google Authenticator or Authy for TOTP',
    'TOTP',
  ),
  email(
    'Email Verification',
    'Receive one-time passcodes via your registered email',
    'Email',
  );

  final String title;
  final String description;
  final String badge;
  const TwoFactorMethod(this.title, this.description, this.badge);
}

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

class CountryOption {
  final String name;
  final String dialCode;
  final String flagEmoji;
  final String? flagAsset;

  const CountryOption({
    required this.name,
    required this.dialCode,
    required this.flagEmoji,
    this.flagAsset,
  });

  static const List<CountryOption> supported = [
    CountryOption(
      name: 'Nigeria',
      dialCode: '+234',
      flagEmoji: '🇳🇬',
      flagAsset: AppAssets.flagNigeria,
    ),
    CountryOption(
      name: 'United States',
      dialCode: '+1',
      flagEmoji: '🇺🇸',
      flagAsset: AppAssets.flagUsa,
    ),
    CountryOption(
      name: 'United Kingdom',
      dialCode: '+44',
      flagEmoji: '🇬🇧',
      flagAsset: AppAssets.flagUk,
    ),
    CountryOption(
      name: 'Kenya',
      dialCode: '+254',
      flagEmoji: '🇰🇪',
      flagAsset: AppAssets.flagKenya,
    ),
    CountryOption(
      name: 'Ghana',
      dialCode: '+233',
      flagEmoji: '🇬🇭',
      flagAsset: AppAssets.flagGhana,
    ),
  ];
}

class SignUpDraft {
  final String contactValue;
  final bool isPhoneContact;
  final CountryOption phoneCountry;
  final String firstName;
  final String lastName;
  final CountryOption? country;
  final String address;
  final String tapTag;
  final String bvn;

  const SignUpDraft({
    this.contactValue = '',
    this.isPhoneContact = false,
    this.phoneCountry = const CountryOption(
      name: 'Nigeria',
      dialCode: '+234',
      flagEmoji: '🇳🇬',
      flagAsset: AppAssets.flagNigeria,
    ),
    this.firstName = '',
    this.lastName = '',
    this.country,
    this.address = '',
    this.tapTag = '',
    this.bvn = '',
  });

  SignUpDraft copyWith({
    String? contactValue,
    bool? isPhoneContact,
    CountryOption? phoneCountry,
    String? firstName,
    String? lastName,
    CountryOption? country,
    String? address,
    String? tapTag,
    String? bvn,
  }) {
    return SignUpDraft(
      contactValue: contactValue ?? this.contactValue,
      isPhoneContact: isPhoneContact ?? this.isPhoneContact,
      phoneCountry: phoneCountry ?? this.phoneCountry,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      address: address ?? this.address,
      tapTag: tapTag ?? this.tapTag,
      bvn: bvn ?? this.bvn,
    );
  }
}
