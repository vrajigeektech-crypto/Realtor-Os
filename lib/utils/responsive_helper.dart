import 'package:flutter/material.dart';

/// Breakpoints used across the whole app.
enum ScreenSize { mobile, tablet, desktop }

class ResponsiveHelper {
  ResponsiveHelper._();

  static const double _mobileBreak  = 600;
  static const double _desktopBreak = 1024;

  static ScreenSize of(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w < _mobileBreak)  return ScreenSize.mobile;
    if (w < _desktopBreak) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext ctx)  => of(ctx) == ScreenSize.mobile;
  static bool isTablet(BuildContext ctx)  => of(ctx) == ScreenSize.tablet;
  static bool isDesktop(BuildContext ctx) => of(ctx) == ScreenSize.desktop;

  /// Returns a value based on current screen size.
  static T value<T>(
    BuildContext ctx, {
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    switch (of(ctx)) {
      case ScreenSize.mobile:  return mobile;
      case ScreenSize.tablet:  return tablet;
      case ScreenSize.desktop: return desktop;
    }
  }

  static EdgeInsets pagePadding(BuildContext ctx) => value(
    ctx,
    mobile:  const EdgeInsets.all(14),
    tablet:  const EdgeInsets.all(20),
    desktop: const EdgeInsets.all(28),
  );
}

/// Convenience builder that rebuilds whenever layout changes.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext ctx, ScreenSize size) builder;

  @override
  Widget build(BuildContext ctx) =>
      builder(ctx, ResponsiveHelper.of(ctx));
}
