import '../../../../app/config/app_assets.dart';

class Beneficiary {
  final String id;
  final String name;
  final String handle;
  final String initials;
  final String? avatarUrl;

  const Beneficiary({
    required this.id,
    required this.name,
    required this.handle,
    required this.initials,
    this.avatarUrl,
  });
}

class DashboardNotification {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final bool isRead;

  const DashboardNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    this.isRead = false,
  });
}

enum WalletCurrency {
  ngn(
    'NGN',
    'Nigerian Naira (NGN)',
    '₦',
    '🇳🇬',
    1.0,
    flagAsset: AppAssets.flagNigeria,
  ),
  usd(
    'USD',
    'United States Dollar (USD)',
    '\$',
    '🇺🇸',
    0.00065,
    flagAsset: AppAssets.flagUsa,
  ),
  gbp(
    'GBP',
    'Great Britain Pound (GBP)',
    '£',
    '🇬🇧',
    0.00051,
    flagAsset: AppAssets.flagUk,
  ),
  eur('EUR', 'Euro (EUR)', '€', '🇪🇺', 0.00060),
  kes(
    'KES',
    'Kenyan Shillings (KES)',
    'KSh',
    '🇰🇪',
    0.084,
    flagAsset: AppAssets.flagKenya,
  );

  final String code;
  final String label;
  final String symbol;
  final String flagEmoji;
  final double rateFromNgn;
  final String? flagAsset;

  const WalletCurrency(
    this.code,
    this.label,
    this.symbol,
    this.flagEmoji,
    this.rateFromNgn, {
    this.flagAsset,
  });
}

class PaymentCard {
  final String id;
  final String holderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;

  const PaymentCard({
    required this.id,
    required this.holderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
  });

  String get cleanNumber => cardNumber.replaceAll(RegExp(r'\s+'), '');

  String get last4Digits {
    final clean = cleanNumber;
    if (clean.length < 4) return clean;
    return clean.substring(clean.length - 4);
  }

  String get maskedNumber {
    final last4 = last4Digits;
    return '•••• •••• •••• $last4';
  }

  String get cardType {
    final clean = cleanNumber;
    if (clean.startsWith('4')) return 'Visa';
    if (clean.startsWith('5')) return 'Mastercard';
    if (clean.startsWith('506') || clean.startsWith('6500')) return 'Verve';
    return 'Debit Card';
  }
}

