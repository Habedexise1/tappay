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
import 'signup_tag_screen.dart';

class SignUpAddressScreen extends StatefulWidget {
  const SignUpAddressScreen({super.key});

  @override
  State<SignUpAddressScreen> createState() => _SignUpAddressScreenState();
}

class _SignUpAddressScreenState extends State<SignUpAddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  CountryOption? _selectedCountry;
  String? _errorText;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final picked = await showCountryPickerSheet(
      context: context,
      title: 'Select country',
      selectedCountry: _selectedCountry,
      showDialCode: false,
    );
    if (picked != null) {
      setState(() {
        _selectedCountry = picked;
        _errorText = null;
      });
    }
  }

  void _onNext() {
    final address = _addressController.text.trim();
    if (_selectedCountry == null || address.isEmpty) {
      setState(
        () => _errorText = 'Please select your country and enter your address',
      );
      return;
    }

    context.read<AuthController>().updateSignUpAddress(
      country: _selectedCountry,
      address: address,
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpTagScreen()));
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
              const OnboardingStepHeader(step: 2),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Your home address',
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
                        'Home address is important to validate\nyour KYC',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 18,
                          color: textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 46),
                      Text(
                        'Country',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickCountry,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.transparent : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor, width: 1.1),
                          ),
                          child: Row(
                            children: [
                              if (_selectedCountry != null) ...[
                                FlagIcon(
                                  assetPath: _selectedCountry!.flagAsset,
                                  fallbackEmoji: _selectedCountry!.flagEmoji,
                                  height: 30,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _selectedCountry!.name,
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textPrimary,
                                  ),
                                ),
                              ] else
                                Text(
                                  'Select country',
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextMuted,
                                  ),
                                ),
                              const Spacer(),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Address',
                        hintText:
                            'Enter your address example: No. 55 Edu Street, Lagos, State',
                        controller: _addressController,
                        maxLines: 4,
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
