import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../utils/responsive_utils.dart';

class SettingsPalette {
  final bool isDark;
  const SettingsPalette._(this.isDark);

  factory SettingsPalette.of(BuildContext context) =>
      SettingsPalette._(Theme.of(context).brightness == Brightness.dark);

  Color get canvas => isDark ? AppColors.darkCanvas : AppColors.lightCanvas;
  Color get card => isDark ? AppColors.darkCard : Colors.white;
  Color get heading => isDark ? AppColors.darkTextPrimary : Colors.black;
  Color get title =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get body => isDark ? AppColors.darkTextSecondary : AppColors.slate500;
  Color get icon => isDark ? Colors.white : AppColors.slate700;
  Color get muted => isDark ? AppColors.darkTextSecondary : AppColors.slate400;
  Color get divider => isDark ? AppColors.darkDivider : AppColors.slate200;
  Color get filledField => isDark ? AppColors.darkCard : AppColors.slate100;
  Color get fieldBorder => isDark ? AppColors.slate500 : AppColors.slate700;
}

class SettingsPageScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? bottomAction;
  final VoidCallback? onBack;
  final bool showBack;
  final bool scrollable;

  const SettingsPageScaffold({
    super.key,
    required this.body,
    this.title,
    this.bottomAction,
    this.onBack,
    this.showBack = true,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 32,
              height: 1.19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: palette.heading,
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (scrollable) body else Expanded(child: body),
      ],
    );

    return Scaffold(
      backgroundColor: palette.canvas,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 560,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
                child: showBack
                    ? SettingsBackButton(onPressed: onBack)
                    : const SizedBox(height: 48),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: scrollable
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: content,
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: content,
                      ),
              ),
              if (bottomAction != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: bottomAction,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SettingsBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return IconButton(
      key: const ValueKey('settings_back_btn'),
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back, size: 28, color: palette.heading),
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final bool positive;

  const StatusChip({super.key, required this.label, this.positive = true});

  @override
  Widget build(BuildContext context) {
    final bg = positive
        ? AppColors.successTint
        : AppColors.primaryYellow.withValues(alpha: 0.22);
    final fg = positive ? AppColors.successText : const Color(0xFFB45309);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Gordita',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
