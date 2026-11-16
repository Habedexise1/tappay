import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';

class AppNavItem {
  final String label;
  final String activeSvg;
  final String inactiveSvg;

  const AppNavItem({
    required this.label,
    required this.activeSvg,
    required this.inactiveSvg,
  });
}

/// Figma "Nav Bar": 70px bar on the canvas colour with a hairline top
/// border; the active tab shows its filled icon and label in brand green.
class AppBottomNavBar extends StatelessWidget {
  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.darkCanvas : AppColors.lightCanvas;
    final divider = isDark ? AppColors.darkDivider : AppColors.slate200;
    final inactive = isDark ? AppColors.darkTextSecondary : AppColors.slate500;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border(top: BorderSide(color: divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    inactiveColor: inactive,
                    onTap: () {
                      if (i != currentIndex) HapticFeedback.selectionClick();
                      onTap(i);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final AppNavItem item;
  final bool selected;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryGreen : inactiveColor;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        key: ValueKey('nav_${item.label}'),
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: SvgPicture.asset(
                selected ? item.activeSvg : item.inactiveSvg,
                key: ValueKey(selected),
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
