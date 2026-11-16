import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? titleWidget;
  final Widget? trailing;
  final bool showDragHandle;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double maxWidth;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  final bool expand;

  static const double minTopGap = 56;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.titleWidget,
    this.trailing,
    this.showDragHandle = true,
    this.padding,
    this.backgroundColor,
    this.maxWidth = 680,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg =
        backgroundColor ??
        (isDark ? AppColors.darkBackground : AppColors.lightBackground);
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final handleColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    final statusBar = MediaQueryData.fromView(View.of(context)).padding.top;
    final topGap = expand
        ? (statusBar + 12 > minTopGap ? statusBar + 12 : minTopGap)
        : 0.0;

    return Padding(
      padding: EdgeInsets.only(top: topGap),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Material(
            color: sheetBg,
            clipBehavior: Clip.antiAlias,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              height: expand ? double.infinity : null,
              padding: padding ?? const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: expand ? MainAxisSize.max : mainAxisSize,
                  crossAxisAlignment: crossAxisAlignment,
                  children: [
                    if (showDragHandle) ...[
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: handleColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (title != null ||
                        titleWidget != null ||
                        trailing != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child:
                                titleWidget ??
                                Text(
                                  title ?? '',
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: titleColor,
                                  ),
                                ),
                          ),
                          ?trailing,
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (expand) Expanded(child: child) else child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  Widget? titleWidget,
  Widget? trailing,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
  bool showDragHandle = true,
  EdgeInsetsGeometry? padding,
  Color? backgroundColor,
  double maxWidth = 680,
  bool useRootNavigator = false,
  bool resizeToAvoidBottomInset = true,
  bool expand = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final sheet = AppBottomSheet(
        title: title,
        titleWidget: titleWidget,
        trailing: trailing,
        showDragHandle: showDragHandle,
        padding: padding,
        backgroundColor: backgroundColor,
        maxWidth: maxWidth,
        expand: expand,
        child: builder(sheetContext),
      );

      if (resizeToAvoidBottomInset) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: sheet,
        );
      }
      return sheet;
    },
  );
}
