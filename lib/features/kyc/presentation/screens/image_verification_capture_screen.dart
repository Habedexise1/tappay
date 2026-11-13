import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../kyc_controller.dart';
import 'image_verification_thank_you_screen.dart';

class ImageVerificationCaptureScreen extends StatelessWidget {
  const ImageVerificationCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kycController = context.read<KycController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Image verification',
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Please fit your face in the oval frame and\ntake the selfie',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 13,
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 240,
                  height: 310,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141816),
                    borderRadius: BorderRadius.circular(155),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.face_retouching_natural_rounded,
                      size: 112,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: GestureDetector(
                  key: const ValueKey('capture_selfie_button'),
                  onTap: () {
                    kycController.captureSelfie();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const ImageVerificationThankYouScreen(),
                      ),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primaryYellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
