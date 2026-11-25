import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/presentation/utils/habit_color_style.dart';
import 'package:evolo/features/habits/presentation/utils/habit_icons.dart';
import 'package:evolo/features/habits/presentation/utils/habit_labels.dart';
import 'package:material_ui/material_ui.dart';

/// Every habit icon, shown inline as a wrapping grid (one tap to choose).
///
/// The selected icon is drawn on the habit's own tile color with a thick ring,
/// so the choice is not told by color alone, and it also previews the habit.
class HabitIconPicker extends StatelessWidget {
  const new({
    required this.selectedKey,
    required this.color,
    required this.onSelected,
    this.enabled = true,
    super.key,
  });

  final String selectedKey;

  /// Only used to paint the selected icon like the habit will look.
  final HabitColor color;
  final ValueChanged<String> onSelected;
  final bool enabled;

  static const double _size = 48;
  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Wrap(
        spacing: _gap,
        runSpacing: _gap,
        children: [
          for (final key in HabitIcons.keys)
            _IconOption(
              key: ValueKey('icon-$key'),
              iconKey: key,
              color: color,
              isSelected: key == selectedKey,
              onTap: enabled ? () => onSelected(key) : null,
            ),
        ],
      ),
    );
  }
}

class _IconOption extends StatelessWidget {
  const new({
    required this.iconKey,
    required this.color,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String iconKey;
  final HabitColor color;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: onTap != null,
      label: habitIconName(context.l10n, iconKey),
      excludeSemantics: true,
      onTap: onTap,
      child: SizedBox.square(
        dimension: HabitIconPicker._size,
        child: InkResponse(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color.tileBackground(colors) : colors.surface,
              border: Border.all(
                color: isSelected ? colors.textAccent : colors.outline,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Icon(
                HabitIcons.resolve(iconKey),
                size: 24,
                color: isSelected
                    ? color.tileForeground(colors)
                    : colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
