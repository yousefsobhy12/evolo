import 'package:flutter/widgets.dart';

/// Material 3 window size classes, fixed values in logical pixels.
abstract final class Breakpoints {
  static const double medium = 600;
  static const double expanded = 840;

  /// Widest a page body gets before it is centered (tablets, landscape).
  static const double maxContentWidth = 600;
}

enum WindowSize {
  compact,
  medium,
  expanded;

  static WindowSize fromWidth(double width) {
    if (width >= Breakpoints.expanded) return WindowSize.expanded;
    if (width >= Breakpoints.medium) return WindowSize.medium;
    return WindowSize.compact;
  }
}

extension ResponsiveContext on BuildContext {
  /// `sizeOf` rebuilds only when the size changes, not on every MediaQuery
  /// change (keyboard, padding...).
  WindowSize get windowSize =>
      WindowSize.fromWidth(MediaQuery.sizeOf(this).width);

  bool get isCompact => windowSize == WindowSize.compact;
}
