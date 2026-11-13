import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/config/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/presentation/screens/login_screen.dart';
import '../../auth/presentation/screens/signup/signup_contact_screen.dart';
import 'widgets/onboarding_indicator.dart';

class WelcomeScreen extends StatefulWidget {
  final bool enableAnimations;

  const WelcomeScreen({super.key, this.enableAnimations = true});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _openGetStarted() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpContactScreen()));
  }

  void _openLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final contentHeight = math.max(
                      constraints.maxHeight,
                      580.0,
                    );
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        height: contentHeight,
                        child: Stack(
                          children: [
                            PageView(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              children: [
                                _OnboardingSlide(
                                  isDark: isDark,
                                  assetPath: AppAssets.onboardingGlobe,
                                  title: 'Not just\nlocally, it’s\nworldwide',
                                  animate: widget.enableAnimations,
                                ),

                                _OnboardingSlide(
                                  isDark: isDark,
                                  assetPath: AppAssets.onboardingCards,
                                  title: 'Custom\ncards, spend\nwith no limits',
                                  animate: widget.enableAnimations,
                                ),

                                _OnboardingSlide(
                                  isDark: isDark,
                                  assetPath: AppAssets.onboardingSwap,
                                  title: 'Send,\nreceive and\nswap money',
                                  animate: widget.enableAnimations,
                                ),
                              ],
                            ),

                            Positioned(
                              top: 16 + 310 + 36,
                              left: 0,
                              right: 0,
                              child: IgnorePointer(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18.0,
                                  ),
                                  child: OnboardingIndicator(
                                    count: 3,
                                    currentIndex: _currentPage,
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      text: _currentPage == 0 && !isDark
                          ? 'Create an account'
                          : 'Get started',
                      onPressed: _openGetStarted,
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      text: 'Login',
                      variant: AppButtonVariant.outline,
                      onPressed: _openLogin,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final bool isDark;
  final String assetPath;
  final String title;
  final bool animate;

  const _OnboardingSlide({
    required this.isDark,
    required this.assetPath,
    required this.title,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    Widget imageWidget = Image.asset(
      assetPath,
      height: 350,
      fit: BoxFit.contain,
    );

    if (animate) {
      imageWidget = imageWidget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -6, duration: 2400.ms, curve: Curves.easeInOut);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            height: 350,
            alignment: Alignment.center,
            child: imageWidget,
          ),

          const SizedBox(height: 44),

          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  height: 1.15,
                  letterSpacing: -1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
