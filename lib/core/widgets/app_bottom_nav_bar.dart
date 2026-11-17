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

class AppSideNavRail extends StatelessWidget {
  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended;

  const AppSideNavRail({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.extended = false,
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
        border: Border(right: BorderSide(color: divider)),
      ),
      child: SafeArea(
        right: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: extended ? 200 : 92,
          child: Column(
            children: [
              const SizedBox(height: 28),
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: _RailButton(
                    item: items[i],
                    selected: i == currentIndex,
                    extended: extended,
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

class _RailButton extends StatelessWidget {
  final AppNavItem item;
  final bool selected;
  final bool extended;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _RailButton({
    required this.item,
    required this.selected,
    required this.extended,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryGreen : inactiveColor;
    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: SvgPicture.asset(
        selected ? item.activeSvg : item.inactiveSvg,
        key: ValueKey(selected),
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
    final label = Text(
      item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'Gordita',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Material(
        color: selected
            ? AppColors.primaryGreen.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: ValueKey('nav_${item.label}'),
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: extended
                ? Row(
                    children: [
                      icon,
                      const SizedBox(width: 12),
                      Expanded(child: label),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [icon, const SizedBox(height: 6), label],
                  ),
          ),
        ),
      ),
    );
  }
}
