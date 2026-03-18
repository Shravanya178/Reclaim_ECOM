import 'package:flutter/material.dart';

/// Responsive breakpoints for the application
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double widescreen = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static bool isWidescreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= widescreen;

  /// Returns the appropriate value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktop && desktop != null) return desktop;
    if (width >= Breakpoints.mobile && tablet != null) return tablet;
    return mobile;
  }
}

/// Responsive grid column count
int responsiveGridColumns(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 1400) return 5;
  if (width >= 1200) return 4;
  if (width >= 900) return 3;
  if (width >= 600) return 3;
  return 2;
}

/// Content max width for centered layouts
double contentMaxWidth(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 1440) return 1320;
  if (width >= 1200) return 1140;
  if (width >= 900) return 860;
  return width;
}

/// Responsive padding
EdgeInsets responsivePadding(BuildContext context) {
  return Breakpoints.responsive(
    context,
    mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    tablet: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    desktop: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
  );
}

/// A widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop && desktop != null) {
          return desktop!(context);
        }
        if (constraints.maxWidth >= Breakpoints.mobile && tablet != null) {
          return tablet!(context);
        }
        return mobile(context);
      },
    );
  }
}

/// Wraps content in a centered container with max width
class ContentContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ContentContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? contentMaxWidth(context),
        ),
        child: Padding(
          padding: padding ?? responsivePadding(context),
          child: child,
        ),
      ),
    );
  }
}
