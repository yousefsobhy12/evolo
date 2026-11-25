import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// The app's primary button: a thin wrapper over [FilledButton] that adds a
/// loading state.
///
/// While [isLoading] the button is disabled (so it cannot be pressed twice),
/// keeps its colors, and shows a spinner in place of the label. The label
/// stays in the layout (invisible), so the button does not change size.
class EvoloButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.loadingLabel,
    super.key,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;

  final bool isLoading;
  final IconData? icon;

  /// Screen-reader text while loading. Defaults to "Loading".
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.s8),
        ],
        Flexible(child: Text(label)),
      ],
    );

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      // A disabled button is greyed out by default; while loading it should
      // still look like the primary button.
      style: isLoading
          ? FilledButton.styleFrom(
              disabledBackgroundColor: scheme.primary,
              disabledForegroundColor: scheme.onPrimary,
            )
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: !isLoading,
            maintainSize: true,
            maintainState: true,
            maintainAnimation: true,
            child: content,
          ),
          if (isLoading)
            SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: scheme.onPrimary,
                semanticsLabel: loadingLabel ?? context.l10n.loading,
              ),
            ),
        ],
      ),
    );
  }
}
