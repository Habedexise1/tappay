import 'package:flutter/material.dart';

import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../domain/settings_models.dart';
import '../widgets/settings_widgets.dart';

class SettingsInfoScreen extends StatelessWidget {
  final InfoDocument document;

  const SettingsInfoScreen({super.key, required this.document});

  static const _supportEmail = 'support@tappay.app';
  static const _supportPhone = '+234 700 827 7729';

  String get _title => switch (document) {
    InfoDocument.privacyPolicy => 'Privacy Policy',
    InfoDocument.termsAndConditions => 'Terms and Conditions',
    InfoDocument.support => 'Support',
  };

  List<(String, String)> get _sections => switch (document) {
    InfoDocument.privacyPolicy => const [
      (
        'What we collect',
        'Your name, contact details, identity documents submitted for verification, and the transactions you make with TapPay.',
      ),
      (
        'How we use it',
        'To verify your identity, process payments, prevent fraud and meet our regulatory obligations. We never sell your personal data.',
      ),
      (
        'How we protect it',
        'Credentials such as your PIN and password are stored in your device\'s secure enclave (Keychain / Keystore), and the app hides its contents in the app switcher.',
      ),
      (
        'Your choices',
        'You can update your phone number, manage notifications, or delete your account at any time from Settings.',
      ),
    ],
    InfoDocument.termsAndConditions => const [
      (
        'Using TapPay',
        'You must be at least 18 years old and complete identity verification to send or receive money.',
      ),
      (
        'Your security',
        'Keep your PIN, password and two-factor codes private. TapPay will never ask for them by phone, email or chat.',
      ),
      (
        'Transfers',
        'Transfers are final once confirmed with your PIN or biometrics. Check recipient details before you confirm.',
      ),
      (
        'Closing your account',
        'You may delete your account from Edit profile. Outstanding balances must be withdrawn before closure.',
      ),
    ],
    InfoDocument.support => const [
      (
        'We are here to help',
        'Our support team is available 24/7. Tap below to copy our contact details.',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return SettingsPageScaffold(
      title: _title,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (heading, body) in _sections) ...[
            Text(
              heading,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: palette.heading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 14,
                height: 1.55,
                color: palette.body,
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (document == InfoDocument.support) ...[
            _ContactCard(
              icon: Icons.email_rounded,
              label: 'Email',
              value: _supportEmail,
            ),
            const SizedBox(height: 12),
            _ContactCard(
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: _supportPhone,
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: palette.icon),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 12,
                    color: palette.body,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: palette.heading,
                  ),
                ),
              ],
            ),
          ),
          CopyValueButton(
            value: value,
            confirmation: '$label copied',
            size: 20,
            tooltip: 'Copy $label',
          ),
        ],
      ),
    );
  }
}
