import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/success_pop_screen.dart';
import '../../../../core/widgets/app_toggle.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../auth/presentation/screens/change_password_screen.dart';
import '../../../auth/presentation/screens/two_factor/two_factor_screen.dart';
import '../../../auth/presentation/widgets/change_pin_sheet.dart';
import '../../../kyc/presentation/kyc_controller.dart';
import '../../../dashboard/presentation/dashboard_controller.dart';
import '../../../kyc/domain/kyc_models.dart';
import '../../../kyc/presentation/kyc_navigation.dart';
import '../../../onboarding/presentation/welcome_screen.dart';
import '../../domain/settings_models.dart';
import '../settings_controller.dart';
import '../../../../app/config/app_assets.dart';
import '../widgets/settings_widgets.dart';
import 'account_info_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'referrals_screen.dart';
import 'settings_beneficiaries_screen.dart';

enum _Section { account, security, other }

class SettingsHomeScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsHomeScreen({super.key, required this.onBack});

  @override
  State<SettingsHomeScreen> createState() => _SettingsHomeScreenState();
}

class _SettingsHomeScreenState extends State<SettingsHomeScreen> {
  final Set<_Section> _expanded = {};

  void _toggle(_Section section) => setState(() {
    if (!_expanded.remove(section)) _expanded.add(section);
  });

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  void _openFullScreen(Route<void> route) =>
      Navigator.of(context, rootNavigator: true).push(route);

  Future<void> _changePin() async {
    final changed = await ChangePinSheet.show(context);
    if (changed != true || !mounted) return;
    _openFullScreen(
      PageRouteBuilder<void>(
        pageBuilder: (routeContext, _, _) => SuccessPopScreen(
          pageTitle: 'Change PIN',
          message: 'Your transaction PIN has been changed successfully',
          onDone: () => Navigator.of(routeContext).pop(),
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Future<void> _toggleBiometrics(bool enable) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context
        .read<AuthController>()
        .setBiometricsEnabledSecurely(enable);
    if (!ok) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Biometric check was cancelled or is unavailable on this device',
            ),
          ),
        );
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _logOut() async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Log out?',
      message: 'You will need your password to sign back in.',
      confirmLabel: 'Log Out',
    );
    if (!confirmed || !mounted) return;
    final rootNav = Navigator.of(context, rootNavigator: true);
    await context.read<AuthController>().signOut();
    rootNav.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final auth = context.watch<AuthController>();
    final kycFlow = KycFlow.forCurrencyCode(
      context.select<DashboardController, String>(
        (d) => d.selectedCurrency.code,
      ),
    );
    final kycStatus = context.select<KycController, KycStatus>(
      (k) => k.statusFor(kycFlow),
    );
    final theme = context.watch<ThemeController>();
    final profile = settings.profile;

    return SettingsPageScaffold(
      onBack: widget.onBack,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(
            state: settings.profileState,
            onRetry: settings.load,
            onEditProfile: profile == null
                ? null
                : () => _open(const EditProfileScreen()),
          ),
          const SizedBox(height: 20),
          SettingsSectionCard(
            title: 'Account',
            expanded: _expanded.contains(_Section.account),
            onToggle: () => _toggle(_Section.account),
            children: [
              SettingsRow(
                svgAsset: AppAssets.iconPersonalCard,
                label: 'Account Information',
                onTap: () => _open(const AccountInfoScreen()),
              ),
              SettingsRow(
                svgAsset: AppAssets.iconVerify,
                label: 'Account Verification',
                trailing: StatusChip(
                  key: const ValueKey('kyc_status_chip'),
                  label: kycStatus.label,
                  positive: kycStatus == KycStatus.verified,
                ),
                onTap: switch (kycStatus) {
                  KycStatus.verified => () => _open(const AccountInfoScreen()),
                  KycStatus.inReview => () => _showSnack(
                    'Your ${kycFlow.label} KYC is being reviewed. We will notify you when it is complete.',
                  ),
                  _ => () => KycNavigator.start(context, kycFlow),
                },
              ),
              SettingsRow(
                svgAsset: AppAssets.iconPeople,
                label: 'Beneficiaries',
                onTap: () => _open(const SettingsBeneficiariesScreen()),
              ),
              SettingsRow(
                svgAsset: AppAssets.iconNotification,
                label: 'Notification',
                onTap: () => _open(const NotificationSettingsScreen()),
              ),
              SettingsRow(
                svgAsset: AppAssets.iconShare,
                label: 'Referrals',
                onTap: profile == null
                    ? null
                    : () => _open(const ReferralsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsSectionCard(
            title: 'Security',
            expanded: _expanded.contains(_Section.security),
            onToggle: () => _toggle(_Section.security),
            children: [
              SettingsRow(
                svgAsset: AppAssets.iconPasswordCheck,
                label: 'Change Password',
                onTap: () => _openFullScreen(
                  MaterialPageRoute<void>(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                ),
              ),
              SettingsRow(
                svgAsset: AppAssets.iconPasswordCheck,
                label: 'Change PIN',
                onTap: _changePin,
              ),
              SettingsRow(
                svgAsset: AppAssets.iconSecuritySafe,
                label: 'Two-factor Authentication',
                onTap: profile == null
                    ? null
                    : () => _openFullScreen(
                        TwoFactorScreen.route(phoneNumber: profile.phoneNumber),
                      ),
              ),
              SettingsRow(
                icon: Icons.fingerprint_rounded,
                label: 'Enable Biometrics',
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AppToggle(
                    key: const ValueKey('biometrics_toggle'),
                    value: auth.settings.isBiometricsEnabled,
                    onChanged: _toggleBiometrics,
                    semanticsLabel: 'Enable Biometrics',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsSectionCard(
            title: 'Other',
            expanded: _expanded.contains(_Section.other),
            onToggle: () => _toggle(_Section.other),
            children: const [
              SettingsRow(
                svgAsset: AppAssets.iconSecuritySafe,
                label: 'Privacy Policy',
              ),
              SettingsRow(
                svgAsset: AppAssets.iconReceiptText,
                label: 'Terms and Conditions',
              ),
              SettingsRow(svgAsset: AppAssets.iconSupport, label: 'Support'),
            ],
          ),
          const SizedBox(height: 20),
          const SettingsGroupLabel('Appearance'),
          SettingsSwitchCard(
            key: const ValueKey('dark_mode_card'),
            svgAsset: AppAssets.iconMoon,
            label: 'Dark mode',
            value: theme.isDarkMode,
            onChanged: (on) =>
                theme.setThemeMode(on ? ThemeMode.dark : ThemeMode.light),
          ),
          const SizedBox(height: 40),
          Center(
            child: DangerTextButton(
              key: const ValueKey('logout_btn'),
              label: 'Log Out',
              onPressed: _logOut,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ViewState<UserProfile> state;
  final VoidCallback onRetry;
  final VoidCallback? onEditProfile;

  const _ProfileHeader({
    required this.state,
    required this.onRetry,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);

    final identity = switch (state) {
      Success(:final data) => Column(
        children: [
          ProfileAvatar(profile: data),
          const SizedBox(height: 12),
          Text(
            data.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: palette.heading,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.handle,
                style: const TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate500,
                ),
              ),
              CopyValueButton(
                value: data.handle,
                confirmation: 'TapTag copied',
                size: 15,
                tooltip: 'Copy TapTag',
              ),
            ],
          ),
        ],
      ),
      Failure(:final message) => Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Gordita',
              fontSize: 13,
              color: AppColors.accentRed,
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
      _ => const Column(
        children: [
          SkeletonLoader(width: 69, height: 69, borderRadius: 35),
          SizedBox(height: 14),
          SkeletonLoader(width: 96, height: 16),
          SizedBox(height: 10),
          SkeletonLoader(width: 80, height: 14),
          SizedBox(height: 14),
        ],
      ),
    };

    return Column(
      children: [
        identity,
        const SizedBox(height: 10),
        SizedBox(
          width: 220,
          height: 50,
          child: OutlinedButton(
            key: const ValueKey('edit_profile_btn'),
            onPressed: onEditProfile,
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.heading,
              side: const BorderSide(color: AppColors.primaryGreen),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontFamily: 'Gordita',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('Edit profile'),
          ),
        ),
      ],
    );
  }
}
