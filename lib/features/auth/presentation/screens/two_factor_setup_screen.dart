import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/auth_models.dart';
import '../auth_controller.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  late bool _isEnabled;
  late TwoFactorMethod _selectedMethod;

  @override
  void initState() {
    super.initState();
    final authController = context.read<AuthController>();
    _isEnabled = authController.settings.isTwoFactorEnabled;
    _selectedMethod = authController.settings.twoFactorMethod;
  }

  Future<void> _saveSettings() async {
    final authController = context.read<AuthController>();
    await authController.updateTwoFactor(
      enabled: _isEnabled,
      method: _selectedMethod,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Two-Factor Authentication settings updated!'),
          backgroundColor: AppColors.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;
    final authController = context.watch<AuthController>();

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Two-Factor Auth',
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Active Status Header Card
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _isEnabled
                            ? AppColors.primaryGreen.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isEnabled ? Icons.shield_rounded : Icons.shield_outlined,
                        color: _isEnabled ? AppColors.primaryGreen : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Status: ',
                                style: TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _isEnabled
                                      ? AppColors.primaryGreen.withValues(alpha: 0.2)
                                      : Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _isEnabled ? '2FA ACTIVE' : 'DISABLED',
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: _isEnabled ? AppColors.primaryGreen : AppColors.accentRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isEnabled
                                ? 'Your account is protected with two verification steps'
                                : 'Enable 2FA to protect withdrawals and logins',
                            style: TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isEnabled,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) {
                        setState(() {
                          _isEnabled = val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Select 2FA Method',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to receive security verification codes',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Method Options
              ...TwoFactorMethod.values.map((method) {
                final isSelected = _selectedMethod == method;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppCard(
                    onTap: _isEnabled
                        ? () {
                            setState(() {
                              _selectedMethod = method;
                            });
                          }
                        : null,
                    borderRadius: 16,
                    borderSide: isSelected && _isEnabled
                        ? const BorderSide(color: AppColors.primaryGreen, width: 2)
                        : null,
                    child: Row(
                      children: [
                        Icon(
                          switch (method) {
                            TwoFactorMethod.sms => Icons.phone_android_rounded,
                            TwoFactorMethod.authenticator => Icons.security_rounded,
                            TwoFactorMethod.email => Icons.mail_outline_rounded,
                          },
                          color: isSelected && _isEnabled
                              ? AppColors.primaryGreen
                              : textSecondary,
                          size: 26,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.title,
                                style: TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _isEnabled
                                      ? textPrimary
                                      : textSecondary.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                method.description,
                                style: TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Radio<TwoFactorMethod>(
                          value: method,
                          groupValue: _isEnabled ? _selectedMethod : null,
                          activeColor: AppColors.primaryGreen,
                          onChanged: _isEnabled
                              ? (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedMethod = val;
                                    });
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const Spacer(),

              // Save Button
              AppButton(
                text: 'Save 2FA Configuration',
                isLoading: authController.securityState.isLoading,
                onPressed: _saveSettings,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
