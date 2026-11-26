import 'package:evolo/core/extensions/extensions.dart';
import 'package:material_ui/material_ui.dart';

/// The round, surface-colored button of the design (for example the close
/// button of a page header).
///
/// A styled [IconButton], so focus, ripple, disabled state and screen-reader
/// support come from Material.
class CircleIconButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = defaultSize,
    super.key,
  }) : assert(size >= minSize, 'The touch target must be at least 48');

  static const double defaultSize = 56;
  static const double minSize = 48;

  final IconData icon;

  /// Required: the button has no text, so this is also its spoken name.
  final String tooltip;

  /// Null disables the button.
  final VoidCallback? onPressed;

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 24),
      style: IconButton.styleFrom(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        disabledBackgroundColor: colors.surface,
        fixedSize: Size.square(size),
        minimumSize: Size.square(size),
        shape: const CircleBorder(),
      ),
    );
  }
}
