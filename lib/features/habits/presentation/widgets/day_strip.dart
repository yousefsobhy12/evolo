import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:material_ui/material_ui.dart';

/// The week header of the Today screen: month title, previous/next week
/// buttons and seven day cells.
///
/// It only reads the flags of each [TodayDay]. Which days can be opened and
/// which week comes next are decided by `TodayState`, not here.
class DayStrip extends StatelessWidget {
  const new({
    required this.days,
    required this.title,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onSelectDay,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final List<TodayDay> days;

  /// For example "November 2026".
  final String title;
  final bool canGoPrevious;
  final bool canGoNext;
  final ValueChanged<CalendarDay> onSelectDay;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.screen,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Chevrons mirror by themselves in RTL, and "previous" stays
              // on the start side.
              IconButton(
                onPressed: canGoPrevious ? onPrevious : null,
                tooltip: l10n.previousWeek,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                title,
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ).centered().expanded(),
              IconButton(
                onPressed: canGoNext ? onNext : null,
                tooltip: l10n.nextWeek,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          AppSpacing.s8.vSpace,
          Row(
            children: [
              for (final day in days)
                _DayCell(
                  day: day,
                  onTap: () => onSelectDay(day.day),
                ).expanded(),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const new({required this.day, required this.onTap});

  final TodayDay day;
  final VoidCallback onTap;

  /// From the design. At 360 the seven cells get ~45 each, so the circle
  /// shrinks to fit instead of overflowing.
  static const double _maxCircle = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final formatters = context.formatters;
    final date = day.day.toDateTime();

    final Color background;
    final Color foreground;
    if (day.isSelected) {
      background = colors.ink;
      foreground = colors.onInk;
    } else {
      background = colors.dayPill;
      foreground = colors.textPrimary;
    }

    return Semantics(
      button: true,
      selected: day.isSelected,
      enabled: day.isSelectable,
      label: formatters.fullDate(date),
      excludeSemantics: true,
      onTap: day.isSelectable ? onTap : null,
      child: Opacity(
        opacity: day.isSelectable ? 1 : 0.4,
        child: InkResponse(
          onTap: day.isSelectable ? onTap : null,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatters.weekdayNarrow(date),
                  style: context.textTheme.bodySmall,
                ),
                AppSpacing.s4.vSpace,
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxCircle),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: background,
                        // Today gets a ring so it is visible even when
                        // another day is selected.
                        border: day.isToday
                            ? Border.all(color: colors.textAccent, width: 1.5)
                            : null,
                      ),
                      // A big system font would not fit the circle, so the
                      // number scales down instead of overflowing.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.all(4),
                          child: Text(
                            formatters.number(day.day.day),
                            style: context.textTheme.titleMedium?.copyWith(
                              color: foreground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
