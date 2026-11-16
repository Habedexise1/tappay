import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../kyc_navigation.dart';
import '../widgets/kyc_widgets.dart';

/// Figma "IMG Identity verification" intro: guidance plus "Take a selfie".
class KycSelfieIntroScreen extends StatelessWidget {
  const KycSelfieIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      scrollable: false,
      bottomAction: AppButton(
        key: const ValueKey('kyc_take_selfie_btn'),
        text: 'Take a selfie',
        onPressed: () => KycNavigator.openSelfieCamera(context),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KycHeading(
            title: 'Image verification',
            subtitle:
                'Take a well-lit selfie, ensuring your face is clear and unobstructed, and maintain a neutral expression.',
          ),
          SizedBox(height: 24),
          Expanded(child: Center(child: _SelfieIllustration())),
        ],
      ),
    );
  }
}

/// Phone showing a face-scan, standing in for the Figma undraw artwork.
class _SelfieIllustration extends StatelessWidget {
  const _SelfieIllustration();

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.clamp(180.0, 394.0);
        final width = height * 0.56;
        return ExcludeSemantics(
          child: SizedBox(
            width: width + 40,
            height: height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Scan bars to the left of the phone.
                Positioned(
                  left: 0,
                  top: height * 0.26,
                  child: Column(
                    children: [
                      for (var i = 0; i < 4; i++)
                        Container(
                          width: 8,
                          height: height * 0.08,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.35 + i * 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    width: width,
                    height: height,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightTextPrimary,
                      borderRadius: BorderRadius.circular(width * 0.16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(width * 0.13),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: width * 0.55,
                            height: width * 0.55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryGreen,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.face_rounded,
                              size: width * 0.38,
                              color: AppColors.slate700,
                            ),
                          ),
                          SizedBox(height: height * 0.06),
                          Icon(
                            Icons.person_rounded,
                            size: width * 0.5,
                            color: AppColors.primaryYellow,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
