import 'package:evolo/core/extensions/extensions.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// For pages without an `AppBar`: picks the status bar icon color (dark icons
/// on the light background and the other way round).
class PageStatusBar extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: context.isDark
            ? Brightness.light
            : Brightness.dark,
        // iOS describes the background instead of the icons.
        statusBarBrightness: context.theme.brightness,
      ),
      child: child,
    );
  }
}
