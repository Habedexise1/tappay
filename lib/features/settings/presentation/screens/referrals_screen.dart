import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../settings_controller.dart';
import '../widgets/settings_widgets.dart';

class ReferralsScreen extends StatelessWidget {
  const ReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<SettingsController>().profile;
    final palette = SettingsPalette.of(context);
    if (profile == null) {
      return const SettingsPageScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final code = profile.referralCode;

    return SettingsPageScaffold(
      title: 'Refer and Earn',
      bottomAction: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              padding: const EdgeInsets.only(left: 24, right: 8),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SelectableText(
                      code,
                      key: const ValueKey('referral_code_text'),
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: palette.isDark
                            ? palette.heading
                            : AppColors.slate700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  CopyValueButton(
                    value: code,
                    confirmation: 'Referral code copied',
                    size: 20,
                    tooltip: 'Copy referral code',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppColors.primaryGreen,
            shape: const CircleBorder(),
            child: InkWell(
              key: const ValueKey('referral_share_btn'),
              customBorder: const CircleBorder(),
              onTap: context.read<SettingsController>().shareReferral,
              child: SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.iconExport,
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      AppColors.lightTextPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invite your folks to use TapPay and earn rewards. Share your unique referral code or link below',
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 16,
              height: 1.55,
              color: palette.isDark ? palette.body : AppColors.slate700,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 335),
              child: Image.asset(
                AppAssets.referralInvite,
                fit: BoxFit.contain,
                semanticLabel: 'Person inviting friends',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
