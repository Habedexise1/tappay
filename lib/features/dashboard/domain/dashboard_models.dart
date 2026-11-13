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
