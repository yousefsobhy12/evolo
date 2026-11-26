import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

/// The week of the Today screen: seven day cells. Swiping moves between weeks.
///
/// A swipe is invisible to a screen reader, so every cell also offers
/// "previous week" and "next week" as custom accessibility actions.
///
/// It only reads the flags of each [TodayDay]. Which days can be opened and
/// which week comes next are decided by `TodayState`, not here.
class DayStrip extends StatelessWidget {
  const new({
    required this.days,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onSelectDay,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final List<TodayDay> days;
  final bool canGoPrevious;
  final bool canGoNext;
  final ValueChanged<CalendarDay> onSelectDay;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// Logical pixels per second. A slower drag is treated as an accident.
  static const double _minSwipeVelocity = 200;

  void _onSwipeEnd(DragEndDetails details, TextDirection direction) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _minSwipeVelocity) return;

    // The past is on the start side, and dragging toward the end side pulls
    // it into view: to the right in English, to the left in Arabic.
    final towardEnd = direction == TextDirection.ltr
        ? velocity > 0
        : velocity < 0;
    if (towardEnd) {
      if (canGoPrevious) onPrevious();
    } else {
      if (canGoNext) onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final direction = Directionality.of(context);
    final weekActions = <CustomSemanticsAction, VoidCallback>{
      if (canGoPrevious)
        CustomSemanticsAction(label: l10n.previousWeek): onPrevious,
      if (canGoNext) CustomSemanticsAction(label: l10n.nextWeek): onNext,
    };

    return GestureDetector(
      // Opaque: a swipe that starts between two circles counts too.
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) => _onSwipeEnd(details, direction),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.screen,
        ),
        child: Row(
          children: [
            for (final day in days)
              _DayCell(
                day: day,
                weekActions: weekActions,
                onTap: () => onSelectDay(day.day),
              ).expanded(),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const new({
    required this.day,
    required this.weekActions,
    required this.onTap,
  });

  final TodayDay day;
  final Map<CustomSemanticsAction, VoidCallback> weekActions;
  final VoidCallback onTap;

  /// From the design. At 360 the seven cells get ~45 each, so the circle
  /// shrinks to fit instead of overflowing.
  static const double _maxCircle = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final formatters = context.formatters;
    final date = day.day.toDateTime();
    // Arabic has no three-letter day names, and the full ones do not fit a
    // cell, so Arabic keeps the single letter.
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final dayName = isArabic
        ? formatters.weekdayNarrow(date)
        : formatters.weekdayShort(date);

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
      customSemanticsActions: weekActions.isEmpty ? null : weekActions,
      child: Opacity(
        opacity: day.isSelectable ? 1 : 0.4,
        child: InkResponse(
          onTap: day.isSelectable ? onTap : null,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scales down so a big font cannot break "Wed" in two.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    dayName,
                    maxLines: 1,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: day.isSelected ? colors.textPrimary : null,
                      fontWeight: day.isSelected ? FontWeight.w600 : null,
                    ),
                  ),
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
                        // The ring shows where today is while another day
                        // is open. On today itself the dark fill is enough.
                        border: day.isToday && !day.isSelected
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
