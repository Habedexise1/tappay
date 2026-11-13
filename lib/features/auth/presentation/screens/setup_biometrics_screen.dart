import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../auth_controller.dart';
import '../widgets/onboarding_step_header.dart';

class SetupBiometricsScreen extends StatelessWidget {
  const SetupBiometricsScreen({super.key});

  void _openDashboard(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  Future<void> _enableAndContinue(BuildContext context) async {
    final controller = context.read<AuthController>();
    final ok = await controller.authenticateWithBiometrics(
      reason: 'Enable biometrics to secure your TapPay account',
    );
    await controller.toggleBiometrics(ok);
    if (context.mounted) {
      _openDashboard(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              const OnboardingStepHeader(),

              const SizedBox(height: 66),
              GestureDetector(
                onTap: () => _enableAndContinue(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 70,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF14241C)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF283B31)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AppAssets.iconScan,
                    width: 36,
                    height: 36,
                    colorFilter: isDark
                        ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Set up Biometrics',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Add an extra security layer to\nsecure your account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 18,
                  color: textSecondary,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Continue',
                onPressed: () => _enableAndContinue(context),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Skip for now',
                variant: AppButtonVariant.outline,
                onPressed: () => _openDashboard(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
