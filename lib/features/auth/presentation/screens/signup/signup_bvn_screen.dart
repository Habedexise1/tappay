import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../auth_controller.dart';
import '../../widgets/onboarding_step_header.dart';
import 'signup_password_screen.dart';

class SignUpBvnScreen extends StatefulWidget {
  const SignUpBvnScreen({super.key});

  @override
  State<SignUpBvnScreen> createState() => _SignUpBvnScreenState();
}

class _SignUpBvnScreenState extends State<SignUpBvnScreen> {
  final TextEditingController _bvnController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _bvnController.dispose();
    super.dispose();
  }

  void _onNext() {
    final bvn = _bvnController.text.trim();
    if (bvn.length != 11) {
      setState(() => _errorText = 'BVN must be exactly 11 digits');
      return;
    }

    context.read<AuthController>().updateSignUpBvn(bvn);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpPasswordScreen()));
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingStepHeader(step: 4),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'What’s your BVN',
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
                        'By law, your BVN is required to validate\nyour Identity as a TapPay customer',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 18,
                          color: textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 46),
                      AppTextField(
                        label: 'BVN',
                        hintText: 'Enter your BVN',
                        controller: _bvnController,
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        errorText: _errorText,
                        onChanged: (_) {
                          if (_errorText != null) {
                            setState(() => _errorText = null);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your BVN is a 11 digit number from your local\nbank',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 14,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(text: 'Next', onPressed: _onNext),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
