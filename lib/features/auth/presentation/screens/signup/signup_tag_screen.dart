import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../auth_controller.dart';
import '../../widgets/onboarding_step_header.dart';
import 'signup_bvn_screen.dart';

class SignUpTagScreen extends StatefulWidget {
  const SignUpTagScreen({super.key});

  @override
  State<SignUpTagScreen> createState() => _SignUpTagScreenState();
}

class _SignUpTagScreenState extends State<SignUpTagScreen> {
  final TextEditingController _tagController = TextEditingController();
  String _tagPreview = '';

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _onNext({bool skip = false}) {
    final cleaned = skip
        ? ''
        : _tagController.text.trim().replaceFirst(RegExp(r'^@+'), '');
    context.read<AuthController>().updateSignUpTapTag(cleaned);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpBvnScreen()));
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
              const OnboardingStepHeader(step: 3),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Create a TapTag',
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
                        'With TapTag you can send and receive\nmoney without bank account',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 18,
                          color: textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 46),
                      AppTextField(
                        label: 'TapPaytag',
                        hintText: '@Enter a suitable name i.e charlieboy',
                        controller: _tagController,
                        onChanged: (val) {
                          final cleaned = val.trim().replaceFirst(
                            RegExp(r'^@+'),
                            '',
                          );
                          setState(() {
                            _tagPreview = cleaned.isEmpty
                                ? 'charlieboy'
                                : cleaned;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TapPay.app/$_tagPreview',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(text: 'Next', onPressed: () => _onNext()),
              const SizedBox(height: 12),
              AppButton(
                text: 'Skip, I will add the tag later',
                variant: AppButtonVariant.outline,
                onPressed: () => _onNext(skip: true),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
