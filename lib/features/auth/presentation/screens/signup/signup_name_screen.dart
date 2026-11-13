import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../auth_controller.dart';
import '../../widgets/onboarding_step_header.dart';
import 'signup_address_screen.dart';

class SignUpNameScreen extends StatefulWidget {
  const SignUpNameScreen({super.key});

  @override
  State<SignUpNameScreen> createState() => _SignUpNameScreenState();
}

class _SignUpNameScreenState extends State<SignUpNameScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _onNext() {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    if (first.isEmpty || last.isEmpty) {
      setState(() => _errorText = 'Please enter both first and last name');
      return;
    }

    context.read<AuthController>().updateSignUpName(
      firstName: first,
      lastName: last,
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpAddressScreen()));
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
              const OnboardingStepHeader(step: 1),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'What’s your name',
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
                        'Your official name is important to\ncreate an account',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 18,
                          color: textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 46),
                      AppTextField(
                        label: 'First Name',
                        hintText: 'Enter your first name',
                        controller: _firstNameController,
                        onChanged: (_) {
                          if (_errorText != null) {
                            setState(() => _errorText = null);
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Last Name',
                        hintText: 'Enter your last name',
                        controller: _lastNameController,
                        errorText: _errorText,
                        onChanged: (_) {
                          if (_errorText != null) {
                            setState(() => _errorText = null);
                          }
                        },
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
