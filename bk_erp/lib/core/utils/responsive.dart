import 'package:flutter/material.dart';

/// Breakpoints that match Book Keeper's desktop-first design.
/// The app enforces a minimum of 1100 px wide so these stay practical.
class AppBreakpoints {
  AppBreakpoints._();

  static const double compact = 1100; // minimum enforced by OS window
  static const double medium = 1360;
  static const double expanded = 1600;
}

/// Screen-size category for the current build context.
enum ScreenSize { compact, medium, expanded }

/// Responsive helper accessible anywhere via `context.screenSize`,
/// `context.isCompact`, etc.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  ScreenSize get screenSize {
    final w = screenWidth;
    if (w < AppBreakpoints.medium) return ScreenSize.compact;
    if (w < AppBreakpoints.expanded) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isMedium => screenSize == ScreenSize.medium;
  bool get isExpanded => screenSize == ScreenSize.expanded;

  /// Sidebar width based on screen size.
  double get sidebarWidth {
    switch (screenSize) {
      case ScreenSize.compact:
        return 56; // icon-only rail
      case ScreenSize.medium:
        return 200;
      case ScreenSize.expanded:
        return 240;
    }
  }

  /// Whether the sidebar should show labels (i.e. not icon-only).
  bool get showSidebarLabels => !isCompact;

  /// Horizontal content padding that scales with screen width.
  double get contentPadding {
    switch (screenSize) {
      case ScreenSize.compact:
        return 12;
      case ScreenSize.medium:
        return 16;
      case ScreenSize.expanded:
        return 24;
    }
  }
}

/// Responsive builder widget — exposes the [ScreenSize] to its child tree.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ScreenSize size) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, context.screenSize);
  }
}
