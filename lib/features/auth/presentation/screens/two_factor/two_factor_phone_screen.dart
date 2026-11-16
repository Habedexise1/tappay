import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/settings_form_field.dart';
import '../../../../../core/widgets/settings_page_scaffold.dart';
import '../../../domain/auth_models.dart';
import 'two_factor_otp_screen.dart';

class TwoFactorPhoneScreen extends StatelessWidget {
  final String phoneNumber;

  const TwoFactorPhoneScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return SettingsPageScaffold(
      title: 'Two-factor Authentication',
      bottomAction: AppButton(
        key: const ValueKey('two_factor_send_otp_btn'),
        text: 'Send OTP',
        onPressed: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TwoFactorOtpScreen(
              method: TwoFactorMethod.sms,
              mode: TwoFactorOtpMode.activate,
              destination: phoneNumber,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A 6-digit code will be sent to your registered phone number',
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 16,
              height: 1.55,
              color: palette.body,
            ),
          ),
          const SizedBox(height: 30),
          SettingsFormField(
            key: const ValueKey('two_factor_phone_field'),
            label: 'Phone Number',
            initialValue: phoneNumber,
            filled: true,
          ),
        ],
      ),
    );
  }
}
