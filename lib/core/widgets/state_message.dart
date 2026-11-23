import 'dart:math' as math;

import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/core/widgets/max_content_width.dart';
import 'package:material_ui/material_ui.dart';

/// Icon + title + message + optional button, centered in the free space.
///
/// One widget for every Empty and Error state in the app, so they all look
/// the same and S12 only has to review one place.
///
/// It scrolls when the space is too small (a big system font, landscape),
/// instead of overflowing.
class StateMessage extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Defaults to the secondary text color.
  final Color? iconColor;

  /// Usually a `FilledButton`. Omit it when there is nothing to do.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screen,
            vertical: AppSpacing.s24,
          ),
          child: ConstrainedBox(
            // Keeps the content centered when there is room to spare.
            constraints: BoxConstraints(
              minHeight: math.max(
                0,
                constraints.maxHeight - AppSpacing.s24 * 2,
              ),
            ),
            child: Center(
              child: MaxContentWidth(
                maxWidth: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        icon,
                        size: 56,
                        color: iconColor ?? context.colors.textSecondary,
                      ),
                    ),
                    AppSpacing.s16.vSpace,
                    Text(
                      title,
                      style: context.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.s8.vSpace,
                    Text(
                      message,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (action != null) ...[AppSpacing.s24.vSpace, action!],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
