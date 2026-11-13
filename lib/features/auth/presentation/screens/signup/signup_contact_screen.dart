import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/flag_icon.dart';
import '../../../domain/auth_models.dart';
import '../../auth_controller.dart';
import '../../widgets/country_picker_sheet.dart';
import '../../widgets/onboarding_step_header.dart';
import '../login_screen.dart';
import 'verify_account_screen.dart';

class SignUpContactScreen extends StatefulWidget {
  const SignUpContactScreen({super.key});

  @override
  State<SignUpContactScreen> createState() => _SignUpContactScreenState();
}

class _SignUpContactScreenState extends State<SignUpContactScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _usePhone = false;
  CountryOption _selectedCountry = CountryOption.supported.first;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onNext() {
    final authController = context.read<AuthController>();
    if (_usePhone) {
      final phone = _phoneController.text.trim();
      if (phone.length < 7) {
        setState(() => _errorText = 'Please enter a valid phone number');
        return;
      }
      final formatted = phone.startsWith('+')
          ? phone
          : '${_selectedCountry.dialCode}$phone';
      authController.updateSignUpContact(
        value: formatted,
        isPhone: true,
        phoneCountry: _selectedCountry,
      );
      _navigateToVerify(formatted);
    } else {
      final email = _emailController.text.trim();
      if (!email.contains('@') || !email.contains('.')) {
        setState(() => _errorText = 'Please enter a valid email address');
        return;
      }
      authController.updateSignUpContact(value: email, isPhone: false);
      _navigateToVerify(email);
    }
  }

  void _navigateToVerify(String destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerifyAccountScreen(contactTarget: destination),
      ),
    );
  }

  Future<void> _pickCountryCode() async {
    final picked = await showCountryPickerSheet(
      context: context,
      title: 'Select country code',
      selectedCountry: _selectedCountry,
      showDialCode: true,
    );
    if (picked != null) {
      setState(() => _selectedCountry = picked);
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
    final borderColor = isDark
        ? const Color(0xFF44554C)
        : const Color(0xFFA0AEB8);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingStepHeader(
                onBack: _usePhone
                    ? () => setState(() {
                        _usePhone = false;
                        _errorText = null;
                      })
                    : () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        _usePhone
                            ? 'Enter your phone\nnumber'
                            : 'Enter your email\naddress',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          height: 1.2,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _usePhone
                            ? 'Your phone will be used to verify your account.'
                            : 'Your email address will be used to\nverify your account.',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 18,
                          color: textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 25),
                      if (_usePhone) ...[
                        Text(
                          'Phone Number',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _pickCountryCode,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 1.1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FlagIcon(
                                      assetPath: _selectedCountry.flagAsset,
                                      fallbackEmoji: _selectedCountry.flagEmoji,
                                      height: 30,
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 25,
                                      color: textPrimary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppTextField(
                                hintText: _selectedCountry.dialCode,
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                errorText: _errorText,
                                onChanged: (_) {
                                  if (_errorText != null) {
                                    setState(() => _errorText = null);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ] else
                        AppTextField(
                          label: 'Email Address',
                          hintText: 'Enter your email address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _errorText,
                          onChanged: (_) {
                            if (_errorText != null) {
                              setState(() => _errorText = null);
                            }
                          },
                        ),
                      const SizedBox(height: 31),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Already a user? Log in',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(text: 'Next', onPressed: _onNext),
              const SizedBox(height: 12),
              AppButton(
                text: _usePhone ? 'Use email instead' : 'Use phone instead',
                variant: AppButtonVariant.outline,
                onPressed: () {
                  setState(() {
                    _usePhone = !_usePhone;
                    _errorText = null;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
