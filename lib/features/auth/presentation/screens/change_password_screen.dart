import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/settings_form_field.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../../../core/widgets/success_pop_screen.dart';
import '../auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  bool _hideCurrent = true;
  bool _hideNew = true;

  @override
  void initState() {
    super.initState();
    _currentController.addListener(_onEdited);
    _newController.addListener(_onEdited);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthController>().resetPasswordState();
    });
  }

  String _lastCurrent = '';
  String _lastNew = '';

  void _onEdited() {
    if (_currentController.text == _lastCurrent &&
        _newController.text == _lastNew) {
      return;
    }
    _lastCurrent = _currentController.text;
    _lastNew = _newController.text;
    setState(() {});
    context.read<AuthController>().resetPasswordState();
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _currentController.text.isNotEmpty && _newController.text.isNotEmpty;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthController>();
    final ok = await auth.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );
    if (!ok || !mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (routeContext, _, _) => SuccessPopScreen(
          pageTitle: 'Change password',
          message: 'Your password has been changed successfully',
          onDone: () => Navigator.of(routeContext).pop(),
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final state = auth.passwordState;
    final error = state is Failure<bool> ? state.message : null;
    final currentError = error != null && error.contains('Current')
        ? error
        : null;
    final newError = error != null && currentError == null ? error : null;

    return SettingsPageScaffold(
      title: 'Change password',
      bottomAction: AppButton(
        key: const ValueKey('change_password_submit_btn'),
        text: 'Change password',
        isLoading: state is Loading,
        onPressed: _canSubmit ? _submit : null,
      ),
      body: AutofillGroup(
        child: Column(
          children: [
            SettingsFormField(
              key: const ValueKey('current_password_field'),
              label: 'Current Password',
              hintText: 'Enter your current password',
              controller: _currentController,
              obscureText: _hideCurrent,
              errorText: currentError,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.password],
              suffix: PasswordVisibilityToggle(
                obscured: _hideCurrent,
                onPressed: () => setState(() => _hideCurrent = !_hideCurrent),
              ),
            ),
            const SizedBox(height: 16),
            SettingsFormField(
              key: const ValueKey('new_password_field'),
              label: 'New Password',
              hintText: 'Enter new password',
              controller: _newController,
              obscureText: _hideNew,
              errorText: newError,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) {
                if (_canSubmit) _submit();
              },
              suffix: PasswordVisibilityToggle(
                obscured: _hideNew,
                onPressed: () => setState(() => _hideNew = !_hideNew),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
