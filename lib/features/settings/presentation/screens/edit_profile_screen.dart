import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/settings_form_field.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../dashboard/presentation/widgets/confirm_pin_sheet.dart';
import '../../../onboarding/presentation/welcome_screen.dart';
import '../settings_controller.dart';
import '../widgets/settings_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _phoneController;
  late final String _initialPhone;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsController>();
    _initialPhone = settings.profile?.phoneNumber ?? '';
    var lastText = _initialPhone;
    _phoneController = TextEditingController(text: _initialPhone)
      ..addListener(() {
       if (_phoneController.text == lastText) return;
        lastText = _phoneController.text;
        setState(() {});
        settings.resetPhoneUpdateState();
      });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => settings.resetPhoneUpdateState(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      _phoneController.text.trim() !=
      (context.read<SettingsController>().profile?.phoneNumber ??
          _initialPhone);

  Future<void> _savePhone() async {
    if (!_isDirty) return;
    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<SettingsController>().updatePhoneNumber(
      _phoneController.text,
    );
    if (ok) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Phone number updated')));
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Delete account?',
      message:
          'This permanently closes your TapPay account and removes your saved credentials from this device. This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !mounted) return;

    final pin = await ConfirmPinSheet.show(
      context,
      useRootNavigator: true,
      subtitle: 'Enter your PIN to confirm\naccount deletion',
    );
    if (pin != ConfirmPinResult.verified || !mounted) return;

    final settings = context.read<SettingsController>();
    final auth = context.read<AuthController>();
    final rootNav = Navigator.of(context, rootNavigator: true);
    final ok = await settings.deleteAccount();
    if (!ok) return;
    await auth.signOut(wipeDevice: true);
    rootNav.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final profile = settings.profile;
    final palette = SettingsPalette.of(context);
    final phoneState = settings.phoneUpdateState;

    if (profile == null) {
      return const SettingsPageScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SettingsPageScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(profile: profile, size: 48),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: palette.heading,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          profile.handle,
                          style: const TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate500,
                          ),
                        ),
                        CopyValueButton(
                          value: profile.handle,
                          confirmation: 'TapTag copied',
                          size: 15,
                          tooltip: 'Copy TapTag',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsFormField(
            key: ValueKey('profile_name_${profile.fullName}'),
            label: 'Name',
            initialValue: profile.fullName,
            filled: true,
          ),
          const SizedBox(height: 18),
          SettingsFormField(
            key: ValueKey('profile_email_${profile.email}'),
            label: 'Email',
            initialValue: profile.email,
            filled: true,
          ),
          const SizedBox(height: 18),
          SettingsFormField(
            key: ValueKey('profile_tag_${profile.tapTag}'),
            label: 'TapTag',
            initialValue: profile.handle,
            filled: true,
          ),
          const SizedBox(height: 18),
          SettingsFormField(
            key: const ValueKey('profile_phone_field'),
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
              LengthLimitingTextInputFormatter(18),
            ],
            errorText: phoneState is Failure<bool> ? phoneState.message : null,
            onSubmitted: (_) => _savePhone(),
            suffix: !_isDirty
                ? null
                : phoneState is Loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    key: const ValueKey('save_phone_btn'),
                    tooltip: 'Save phone number',
                    onPressed: _savePhone,
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
          ),
          const SizedBox(height: 40),
          Center(
            child: DangerTextButton(
              key: const ValueKey('delete_account_btn'),
              label: 'Delete account',
              isLoading: settings.deleteState is Loading,
              onPressed: _deleteAccount,
            ),
          ),
        ],
      ),
    );
  }
}
