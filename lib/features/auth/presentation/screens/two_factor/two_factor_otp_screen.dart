import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/view_state.dart';
import '../../../../../core/widgets/settings_page_scaffold.dart';
import '../../../../../core/widgets/success_pop_screen.dart';
import '../../../domain/auth_models.dart';
import '../../auth_controller.dart';
import '../../widgets/otp_input_row.dart';
import 'two_factor_screen.dart';

enum TwoFactorOtpMode { activate, deactivate }

class TwoFactorOtpScreen extends StatefulWidget {
  final TwoFactorMethod method;
  final TwoFactorOtpMode mode;

  final String destination;

  const TwoFactorOtpScreen({
    super.key,
    required this.method,
    required this.mode,
    required this.destination,
  });

  @override
  State<TwoFactorOtpScreen> createState() => _TwoFactorOtpScreenState();
}

class _TwoFactorOtpScreenState extends State<TwoFactorOtpScreen> {
  final _otpController = TextEditingController();

  bool get _isSms => widget.method == TwoFactorMethod.sms;
  bool get _isActivate => widget.mode == TwoFactorOtpMode.activate;

  String get _title =>
      '${_isActivate ? 'Activate' : 'Deactivate'} ${widget.method.title}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthController>()..resetOtpState();
      if (_isSms) auth.startOtpTimer(seconds: 60);
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  String _formatTimer(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  Future<void> _submit(String code) async {
    final auth = context.read<AuthController>();
    if (auth.otpState is Loading) return;

    final ok = _isActivate
        ? await auth.activateTwoFactor(method: widget.method, otp: code)
        : await auth.deactivateTwoFactor(code);
    if (!mounted) return;
    if (!ok) {
      HapticFeedback.heavyImpact();
      _otpController.clear();
      return;
    }

    final verb = _isActivate ? 'activated' : 'deactivated';
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (routeContext, _, _) => SuccessPopScreen(
          pageTitle: 'Two-factor Authentication',
          message:
              'Your two-factor authentication ${widget.method.title} has been $verb',
          onDone: () => Navigator.of(
            routeContext,
          ).popUntil(ModalRoute.withName(TwoFactorScreen.routeName)),
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final palette = SettingsPalette.of(context);
    final otpState = auth.otpState;
    final isVerifying = otpState is Loading;
    final error = otpState is Failure<bool> ? otpState.message : null;

    final subtitle = _isSms
        ? 'A 6-digit code has been sent to your registered phone number'
        : _isActivate
        ? 'Add this key to your authenticator app, then enter the 6-digit code it generates'
        : 'Enter the 6-digit code from your authenticator app';

    return SettingsPageScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 32,
              height: 1.19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: palette.heading,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 16,
              height: 1.55,
              color: palette.body,
            ),
          ),
          if (!_isSms && _isActivate) ...[
            const SizedBox(height: 20),
            _SecretKeyCard(secret: auth.prepareTwoFactorSecret()),
          ],
          const SizedBox(height: 23),
          OtpInputRow(
            key: const ValueKey('two_factor_otp_input'),
            controller: _otpController,
            onCompleted: _submit,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                if (isVerifying)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  )
                else if (error != null)
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 12,
                        color: AppColors.accentRed,
                      ),
                    ),
                  )
                else if (_isSms)
                  TextButton(
                    key: const ValueKey('two_factor_resend_btn'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: auth.canResendOtp ? auth.resendOtp : null,
                    child: Text(
                      auth.canResendOtp
                          ? 'Resend code'
                          : 'Resend code in ${_formatTimer(auth.otpCountdown)}',
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: auth.canResendOtp
                            ? AppColors.primaryGreenDark
                            : palette.title,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecretKeyCard extends StatelessWidget {
  final String secret;

  const _SecretKeyCard({required this.secret});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final grouped = RegExp(
      '.{1,4}',
    ).allMatches(secret).map((m) => m.group(0)).join(' ');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.key_rounded, size: 22, color: palette.icon),
          const SizedBox(width: 14),
          Expanded(
            child: SelectableText(
              grouped,
              key: const ValueKey('two_factor_secret_text'),
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: palette.heading,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copy secret key',
            icon: Icon(Icons.copy_rounded, size: 20, color: palette.icon),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: secret));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Secret key copied')),
                );
            },
          ),
        ],
      ),
    );
  }
}
