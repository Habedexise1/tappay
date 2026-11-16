import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../app/config/app_assets.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/settings_page_scaffold.dart';
import '../../../domain/auth_models.dart';
import '../../auth_controller.dart';
import 'two_factor_otp_screen.dart';
import 'two_factor_phone_screen.dart';

class TwoFactorScreen extends StatelessWidget {
  static const routeName = '/settings/two-factor';

  final String phoneNumber;

  const TwoFactorScreen({super.key, required this.phoneNumber});

  static Route<void> route({required String phoneNumber}) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: routeName),
      builder: (_) => TwoFactorScreen(phoneNumber: phoneNumber),
    );
  }

  Future<void> _activate(BuildContext context) async {
    final method = await _SelectTwoFactorSheet.show(context);
    if (method == null || !context.mounted) return;

    final next = switch (method) {
      TwoFactorMethod.sms => TwoFactorPhoneScreen(phoneNumber: phoneNumber),
      _ => TwoFactorOtpScreen(
        method: method,
        mode: TwoFactorOtpMode.activate,
        destination: phoneNumber,
      ),
    };
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => next));
  }

  void _deactivate(BuildContext context, TwoFactorMethod method) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TwoFactorOtpScreen(
          method: method,
          mode: TwoFactorOtpMode.deactivate,
          destination: phoneNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AuthController>().settings;
    final palette = SettingsPalette.of(context);

    if (settings.isTwoFactorEnabled) {
      final method = settings.twoFactorMethod;
      return SettingsPageScaffold(
        title: 'Two-factor Authentication',
        bottomAction: AppButton(
          key: const ValueKey('two_factor_deactivate_btn'),
          text: 'Deactivate',
          onPressed: () => _deactivate(context, method),
        ),
        body: _TwoFactorMethodCard(method: method, isActive: true),
      );
    }

    return SettingsPageScaffold(
      title: 'Two-factor Authentication',
      scrollable: false,
      bottomAction: AppButton(
        key: const ValueKey('two_factor_activate_btn'),
        text: 'Activate',
        onPressed: () => _activate(context),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppAssets.shieldPin, width: 91, height: 95),
              const SizedBox(height: 28),
              Text(
                'Add another layer of security to safeguard access to your account and funds',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 14,
                  height: 1.45,
                  color: palette.body,
                ),
              ),
              const SizedBox(height: 72),
            ],
          ),
        ),
      ),
    );
  }
}

class _TwoFactorMethodCard extends StatelessWidget {
  final TwoFactorMethod method;
  final bool isActive;
  final VoidCallback? onTap;

  const _TwoFactorMethodCard({
    required this.method,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: ValueKey('two_factor_option_${method.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: palette.divider),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                method == TwoFactorMethod.sms
                    ? AppAssets.iconMessage
                    : AppAssets.iconKey,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(palette.heading, BlendMode.srcIn),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.title,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: palette.heading,
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          const StatusChip(label: 'Active'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      method.description,
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 12,
                        height: 1.6,
                        color: palette.body,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectTwoFactorSheet extends StatelessWidget {
  const _SelectTwoFactorSheet();

  static Future<TwoFactorMethod?> show(BuildContext context) {
    return showAppBottomSheet<TwoFactorMethod>(
      context: context,
      title: 'Two-factor Authentication',
      builder: (_) => const _SelectTwoFactorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final method in const [
          TwoFactorMethod.sms,
          TwoFactorMethod.authenticator,
        ]) ...[
          _TwoFactorMethodCard(
            method: method,
            onTap: () => Navigator.of(context).pop(method),
          ),
          const SizedBox(height: 25),
        ],
      ],
    );
  }
}
