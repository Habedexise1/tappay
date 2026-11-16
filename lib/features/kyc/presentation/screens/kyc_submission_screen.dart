import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../domain/kyc_models.dart';
import '../kyc_controller.dart';
import '../kyc_navigation.dart';
import '../widgets/kyc_widgets.dart';

/// Figma "Uploading information", "Successful" and "Failed" frames.
class KycSubmissionScreen extends StatefulWidget {
  const KycSubmissionScreen({super.key});

  @override
  State<KycSubmissionScreen> createState() => _KycSubmissionScreenState();
}

class _KycSubmissionScreenState extends State<KycSubmissionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<KycController>().submit();
    });
  }

  void _tryAgain(KycController kyc) {
    final photoRejected = kyc.statusFor(kyc.flow) == KycStatus.failed;
    if (photoRejected) {
      kyc.retrySelfie();
      KycNavigator.openSelfieCamera(context, replace: true);
    } else {
      kyc.submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final kyc = context.watch<KycController>();
    final state = kyc.submission;
    final uploading = state is Loading || state is Initial;

    return PopScope(
      canPop: !uploading,
      child: switch (state) {
        Success() => _ResultView(
          lottie: AppAssets.lottieSuccess,
          title: 'Thank you!',
          message:
              'Your data is being processed. Our team is reviewing your submission to ensure security and compliance, and will notify you when it is complete.',
          buttonText: 'Continue',
          onPressed: () => KycNavigator.close(context),
        ),
        Failure(:final message) => _ResultView(
          lottie: AppAssets.lottieFailed,
          title: 'Verification failed',
          message: message,
          buttonText: 'Try again',
          onPressed: () => _tryAgain(kyc),
        ),
        _ => _UploadingView(progress: kyc.uploadProgress),
      },
    );
  }
}

class _UploadingView extends StatelessWidget {
  final double progress;

  const _UploadingView({required this.progress});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return SettingsPageScaffold(
      showBack: false,
      scrollable: false,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Uploading information please wait...',
              key: const ValueKey('kyc_uploading_text'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 24,
                height: 1.33,
                fontWeight: FontWeight.w700,
                color: palette.heading,
              ),
            ),
            const SizedBox(height: 33),
            Semantics(
              label: 'Upload progress',
              value: '${(progress * 100).round()}%',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 320,
                  height: 8,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: const Duration(milliseconds: 200),
                    builder: (_, value, _) => LinearProgressIndicator(
                      value: value,
                      backgroundColor: palette.divider,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final String lottie;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const _ResultView({
    required this.lottie,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      scrollable: false,
      onBack: onPressed,
      bottomAction: AppButton(
        key: const ValueKey('kyc_result_btn'),
        text: buttonText,
        onPressed: onPressed,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                lottie,
                width: 100,
                height: 100,
                repeat: false,
                errorBuilder: (_, _, _) =>
                    const SizedBox(width: 100, height: 100),
              ),
              const SizedBox(height: 40),
              KycHeading(
                title: title,
                subtitle: message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
