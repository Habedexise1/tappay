import 'package:flutter/material.dart';

/// Screen breakpoint constants and responsive helper utilities
/// to ensure seamless adaptation across Phone and Tablet form factors.
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Breakpoint threshold distinguishing phones from tablets/large screens.
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;

  /// Checks if current context is in a tablet or larger screen width.
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletBreakpoint;
  }

  /// Checks if current context is in a desktop or wide landscape screen.
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktopBreakpoint;
  }

  /// Adaptive value selector based on device form factor.
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint && desktop != null) {
      return desktop;
    }
    if (width >= tabletBreakpoint && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Maximum content width constraint for tablet and desktop readability.
  static const double maxContentWidth = 840.0;
}

/// A responsive container that centers content and limits width on tablets.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveUtils.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

