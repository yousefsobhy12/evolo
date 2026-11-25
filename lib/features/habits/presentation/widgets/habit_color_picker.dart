import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/presentation/utils/habit_color_style.dart';
import 'package:evolo/features/habits/presentation/utils/habit_labels.dart';
import 'package:material_ui/material_ui.dart';

/// The habit colors as circles. The selected one shows a check mark and a
/// thick ring (not color alone); every circle has an outline so the pale
/// tiles stay visible on the page.
class HabitColorPicker extends StatelessWidget {
  const new({
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    super.key,
  });

  final HabitColor selected;
  final ValueChanged<HabitColor> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final color in HabitColor.values)
            _ColorOption(
              key: ValueKey('color-${color.name}'),
              color: color,
              isSelected: color == selected,
              onTap: enabled ? () => onSelected(color) : null,
            ),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  const new({
    required this.color,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

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
      label: habitColorName(context.l10n, color),
      excludeSemantics: true,
      onTap: onTap,
      child: SizedBox.square(
        dimension: 48,
        child: InkResponse(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.tileBackground(colors),
              border: Border.all(
                color: isSelected ? colors.textAccent : colors.outline,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Icon(
                      Icons.check,
                      size: 24,
                      color: color.tileForeground(colors),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
