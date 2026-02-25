import 'package:flutter/material.dart';

/// Responsive breakpoints for the app
class Breakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}

/// Responsive sizing utilities
class ResponsiveSize {
  final BuildContext context;
  late final double screenWidth;
  late final double screenHeight;
  late final bool isMobile;
  late final bool isTablet;
  late final bool isDesktop;
  late final bool isLargeDesktop;

  ResponsiveSize(this.context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    isMobile = screenWidth < Breakpoints.tablet;
    isTablet = screenWidth >= Breakpoints.tablet && screenWidth < Breakpoints.desktop;
    isDesktop = screenWidth >= Breakpoints.desktop && screenWidth < Breakpoints.largeDesktop;
    isLargeDesktop = screenWidth >= Breakpoints.largeDesktop;
  }

  /// Maximum content width based on screen size
  double get maxContentWidth {
    if (isMobile) return screenWidth;
    if (isTablet) return 600;
    if (isDesktop) return 900;
    return 1200;
  }

  /// Form width for auth screens etc
  double get formWidth {
    if (isMobile) return screenWidth - 48;
    return 400;
  }

  /// Card grid columns
  int get gridColumns {
    if (isMobile) return 1;
    if (isTablet) return 2;
    if (isDesktop) return 3;
    return 4;
  }

  /// Horizontal padding
  double get horizontalPadding {
    if (isMobile) return 16;
    if (isTablet) return 24;
    return 32;
  }

  /// Font sizes
  double get titleFontSize => isMobile ? 20 : 24;
  double get headingFontSize => isMobile ? 16 : 18;
  double get bodyFontSize => isMobile ? 14 : 14;
  double get smallFontSize => isMobile ? 12 : 13;

  /// Spacing
  double get cardSpacing => isMobile ? 12 : 16;
  double get sectionSpacing => isMobile ? 20 : 28;

  /// Icon sizes
  double get iconSize => isMobile ? 20 : 24;
  double get largeIconSize => isMobile ? 48 : 64;
}

/// A wrapper widget that constrains content width for web/desktop
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveSize(context);
    final effectiveMaxWidth = maxWidth ?? responsive.maxContentWidth;
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: responsive.horizontalPadding,
      vertical: 16,
    );

    Widget content = Container(
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
      padding: effectivePadding,
      child: child,
    );

    if (centerContent) {
      content = Center(child: content);
    }

    return content;
  }
}

/// Responsive scaffold that wraps content properly for web
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final double? maxWidth;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor ?? Colors.grey.shade50,
      body: ResponsiveContainer(
        maxWidth: maxWidth,
        child: body,
      ),
    );
  }
}

/// Extension to easily get responsive values
extension ResponsiveContextExtension on BuildContext {
  ResponsiveSize get responsive => ResponsiveSize(this);
}
