import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tappay/app/config/app_assets.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toggle.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../domain/settings_models.dart';

class ProfileAvatar extends StatelessWidget {
  final UserProfile profile;
  final double size;

  const ProfileAvatar({super.key, required this.profile, this.size = 69});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.successTint,
      ),
      child: Text(
        profile.initials,
        style: TextStyle(
          fontFamily: 'Gordita',
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          color: AppColors.successText,
        ),
      ),
    );

    final asset = profile.avatarAsset;
    return Semantics(
      image: true,
      label: '${profile.fullName} profile photo',
      child: ClipOval(
        child: asset == null
            ? fallback
            : Image.asset(
                asset,
                width: size,
                height: size,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class CopyValueButton extends StatelessWidget {
  final String value;
  final String confirmation;
  final double size;
  final String tooltip;

  const CopyValueButton({
    super.key,
    required this.value,
    required this.confirmation,
    this.size = 16,
    this.tooltip = 'Copy',
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: SvgPicture.asset(
        AppAssets.iconCopy,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(palette.icon, BlendMode.srcIn),
      ),
      onPressed: () {
        HapticFeedback.selectionClick();
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(confirmation)));
      },
    );
  }
}

class SettingsSectionCard extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Column(
      children: [
        Material(
          color: palette.card,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            key: ValueKey('settings_section_$title'),
            borderRadius: BorderRadius.circular(8),
            onTap: onToggle,
            child: Semantics(
              button: true,
              expanded: expanded,
              child: SizedBox(
                height: 58,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: palette.heading,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: expanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 30,
                          color: palette.heading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(children: children),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    this.icon,
    this.svgAsset,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return InkWell(
      key: ValueKey('settings_row_$label'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 8),
          child: Row(
            children: [
              if (svgAsset != null)
                SvgPicture.asset(
                  svgAsset!,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(palette.icon, BlendMode.srcIn),
                )
              else if (icon != null)
                Icon(icon, size: 22, color: palette.icon),
              const SizedBox(width: 22),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: palette.heading,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsSwitchCard extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsSwitchCard({
    super.key,
    this.icon,
    this.svgAsset,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 20, right: 24),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (svgAsset != null)
            SvgPicture.asset(
              svgAsset!,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(palette.icon, BlendMode.srcIn),
            )
          else if (icon != null)
            Icon(icon, size: 22, color: palette.icon),
          const SizedBox(width: 22),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: palette.heading,
              ),
            ),
          ),
          AppToggle(value: value, onChanged: onChanged, semanticsLabel: label),
        ],
      ),
    );
  }
}

class SettingsGroupLabel extends StatelessWidget {
  final String text;

  const SettingsGroupLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Gordita',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: palette.isDark ? palette.body : AppColors.slate700,
        ),
      ),
    );
  }
}

class DangerTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const DangerTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.dangerRed,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.dangerRed,
                  ),
                ),
        ),
      ),
    );
  }
}

Future<bool> confirmDestructiveAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Gordita',
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(fontFamily: 'Gordita', height: 1.45),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const ValueKey('confirm_destructive_btn'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.dangerRed),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
