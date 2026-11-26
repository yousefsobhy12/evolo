import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:material_ui/material_ui.dart';

/// Seven day circles, Saturday first (same order as the Today day strip; the
/// row mirrors by itself in RTL). Tapping toggles a day.
class WeekdayPicker extends StatelessWidget {
  const new({
    required this.selected,
    required this.onToggle,
    this.enabled = true,
    super.key,
  });

  final Set<Weekday> selected;
  final ValueChanged<Weekday> onToggle;
  final bool enabled;

  /// Saturday first.
  static const List<Weekday> displayOrder = [
    Weekday.saturday,
    Weekday.sunday,
    Weekday.monday,
    Weekday.tuesday,
    Weekday.wednesday,
    Weekday.thursday,
    Weekday.friday,
  ];

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Row(
        children: [
          for (final day in displayOrder)
            _DayOption(
              key: ValueKey('day-${day.name}'),
              weekday: day,
              isSelected: selected.contains(day),
              onTap: enabled ? () => onToggle(day) : null,
            ).expanded(),
        ],
      ),
    );
  }
}

class _DayOption extends StatelessWidget {
  const new({
    required this.weekday,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Weekday weekday;
  final bool isSelected;
  final VoidCallback? onTap;

  /// At 360 the seven cells get ~45 each, so the circle shrinks to fit.
  static const double _maxCircle = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final formatters = context.formatters;
    // Any date works, only its weekday matters: 2024-01-01 is a Monday.
    final date = DateTime(2024, 1, 1 + weekday.index);

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: onTap != null,
      label: formatters.weekdayFull(date),
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 2,
            vertical: 4,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxCircle),
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colors.ink : colors.dayPill,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(4),
                      child: Text(
                        formatters.weekdayNarrow(date),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: isSelected ? colors.onInk : colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
