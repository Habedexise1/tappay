import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../auth/presentation/screens/enter_pin_screen.dart';
import 'widgets/custom_cards_illustration.dart';
import 'widgets/globe_illustration.dart';
import 'widgets/onboarding_indicator.dart';

/// Welcome & Onboarding screen matching the TapPay Figma community design in both Light and Dark mode.
class WelcomeScreen extends StatefulWidget {
  final bool enableAnimations;

  const WelcomeScreen({
    super.key,
    this.enableAnimations = true,
  });

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

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDarkMode;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          child: Column(
            children: [
              // Top Bar with Theme Toggle Switch
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Small subtle brand mark
                    Text(
                      'tappay.',
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.primaryGreen : const Color(0xFF0D1311),
                        letterSpacing: -0.5,
                      ),
                    ),
                    // Theme Switch Pill
                    IconButton(
                      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          size: 20,
                          color: textPrimary,
                        ),
                      ),
                      onPressed: () => themeController.toggleTheme(),
                    ),
                  ],
                ),
              ),

              // Carousel PageView (Globe & Custom Cards)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    // Slide 1: Worldwide Globe
                    _OnboardingSlide(
                      isDark: isDark,
                      illustration: GlobeIllustration(animate: widget.enableAnimations),
                      title: 'Not just\nlocally, it’s\nworldwide',
                    ),
                    // Slide 2: Custom Cards
                    _OnboardingSlide(
                      isDark: isDark,
                      illustration: CustomCardsIllustration(
                        isDark: isDark,
                        animate: widget.enableAnimations,
                      ),
                      title: 'Custom\ncards, spend\nwith no limits',
                    ),
                  ],
                ),
              ),

              // Page Dots Indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: OnboardingIndicator(
                  count: 2,
                  currentIndex: _currentPage,
                  isDark: isDark,
                ),
              ),

              // Bottom Call-To-Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Primary Green Button ("Get started" / "Create an account")
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EnterPinScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: const Color(0xFF081711),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          _currentPage == 0 && !isDark ? 'Create an account' : 'Get started',
                          style: const TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Secondary Button ("Login")
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EnterPinScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.transparent,
                          foregroundColor: const Color(0xFF081711),
                          side: isDark
                              ? BorderSide.none
                              : const BorderSide(color: Color(0xFF081711), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
  final Widget illustration;
  final String title;

  const _OnboardingSlide({
    required this.isDark,
    required this.illustration,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Illustration container
            illustration,
            const SizedBox(height: 36),
            // Headline
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: textPrimary,
                height: 1.12,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
