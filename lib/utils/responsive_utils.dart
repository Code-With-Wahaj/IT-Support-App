import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
/// and providing consistent layout constraints across the app
class ResponsiveUtils {
  // Breakpoints (in logical pixels)
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Max width constraints for content
  static const double maxMobileWidth = 600;
  static const double maxTabletWidth = 900;
  static const double maxDesktopWidth = 1200;

  /// Get the device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if current device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Get the maximum content width based on screen size
  static double getMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return width;
    } else if (width < tabletBreakpoint) {
      return maxTabletWidth;
    } else {
      return maxDesktopWidth;
    }
  }

  /// Get appropriate grid column count based on screen size
  static int getGridColumnCount(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobileColumns;
      case DeviceType.tablet:
        return tabletColumns;
      case DeviceType.desktop:
        return desktopColumns;
    }
  }

  /// Get responsive padding value
  static double getResponsivePadding(
    BuildContext context, {
    double mobile = 16,
    double tablet = 24,
    double desktop = 32,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 16,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Get value based on device type
  static T valueByDevice<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop }

/// Responsive wrapper widget that centers content with max-width constraint
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? ResponsiveUtils.getMaxWidth(context);
    final effectivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsivePadding(context),
        );

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final columnCount = ResponsiveUtils.getGridColumnCount(
      context,
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
    );

    return GridView.count(
      crossAxisCount: columnCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Responsive card with adaptive sizing
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double? elevation;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding =
        padding ??
        EdgeInsets.all(
          ResponsiveUtils.getResponsivePadding(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
        );

    return Card(
      color: color,
      elevation: elevation ?? 2,
      child: Padding(padding: responsivePadding, child: child),
    );
  }
}
