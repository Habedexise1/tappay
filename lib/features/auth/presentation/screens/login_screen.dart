import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../auth_controller.dart';
import '../widgets/onboarding_step_header.dart';
import 'reset_password_screen.dart';
import 'signup/signup_contact_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool quickUnlockMode;

  const LoginScreen({super.key, this.quickUnlockMode = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool _isQuickUnlock;
  bool _obscurePassword = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _isQuickUnlock = widget.quickUnlockMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_isQuickUnlock && !email.contains('@')) {
      setState(() => _errorText = 'Please enter a valid email address');
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorText = 'Please enter your password');
      return;
    }

    final ok = await context.read<AuthController>().loginWithCredentials(
      email: email.isEmpty ? 'johndoe@example.com' : email,
      password: password,
    );

    if (ok && mounted) {
      _navigateToDashboard();
    }
  }

  Future<void> _onBiometricUnlock() async {
    final ok = await context.read<AuthController>().authenticateWithBiometrics(
      reason: 'Log into your TapPay account',
    );
    if (ok && mounted) {
      _navigateToDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
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
    final isLoading = authController.authFlowState is Loading;

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
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: _isQuickUnlock
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (_isQuickUnlock) ...[
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : const Color(0xFFEFF3F6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.4,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'JD',
                              style: TextStyle(
                                fontFamily: 'Gordita',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      Text(
                        'Welcome back!',
                        textAlign: _isQuickUnlock
                            ? TextAlign.center
                            : TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Log into your account',
                        textAlign: _isQuickUnlock
                            ? TextAlign.center
                            : TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (!_isQuickUnlock) ...[
                        AppTextField(
                          label: 'Email',
                          hintText: 'johndoe@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) {
                            if (_errorText != null) {
                              setState(() => _errorText = null);
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                      ],
                      AppTextField(
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        errorText: _errorText,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: textSecondary,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        onChanged: (_) {
                          if (_errorText != null) {
                            setState(() => _errorText = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 10,
                          spacing: 12,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_isQuickUnlock) {
                                  setState(() {
                                    _isQuickUnlock = false;
                                    _errorText = null;
                                  });
                                } else {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SignUpContactScreen(),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                _isQuickUnlock
                                    ? 'Use another account'
                                    : 'Don’t have an account? Sign Up',
                                style: TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ResetPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot password? Reset',
                                style: TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 44),
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _onBiometricUnlock,
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
                                      ? const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _onBiometricUnlock,
                              child: Text(
                                'Use biometrics',
                                style: TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Next',
                isLoading: isLoading,
                onPressed: _onLogin,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
