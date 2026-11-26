import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_radius.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/features/habits/domain/entities/today_item.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_icon_tile.dart';
import 'package:material_ui/material_ui.dart';

/// The white card of a habit on the Today list. The check circle is outside
/// it (see `HabitTimelineRow`). A counter habit gets a column at the end with
/// its progress and the minus button.
///
/// Pure UI: it draws a [TodayItem] and reports presses. Which press changes
/// the count by how much is decided by `TodayItem` and `TodayCubit`.
class HabitCard extends StatelessWidget {
  const new({
    required this.item,
    required this.onDecrement,
    this.onEdit,
    super.key,
  });

  final TodayItem item;

  final VoidCallback onDecrement;

  /// A press anywhere on the card except the counter column.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Material(
      color: colors.surface,
      // Keeps the ripple inside the rounded corners.
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: ConstrainedBox(
        // 72 from the design, but it grows with a big system font.
        constraints: const BoxConstraints(minHeight: 72),
        child: Row(
          children: [
            Semantics(
              onTapHint: l10n.editHabitTitle,
              child: InkWell(
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.s12),
                  child: Row(
                    children: [
                      HabitIconTile(
                        iconKey: item.habit.iconKey,
                        color: item.habit.color,
                      ),
                      AppSpacing.s12.hSpace,
                      _Details(item: item).expanded(),
                    ],
                  ),
                ),
              ),
            ).expanded(),
            if (item.isCounter)
              _CounterColumn(item: item, onDecrement: onDecrement),
          ],
        ),
      ),
    );
  }
}

/// A divider, then "3 / 8" above the minus button.
///
/// Adding is the job of the circle outside the card, so there is no plus here.
class _CounterColumn extends StatelessWidget {
  const new({required this.item, required this.onDecrement});

  final TodayItem item;
  final VoidCallback onDecrement;

  /// Fixed, so a big count or a big font cannot squeeze the habit name.
  static const double _width = 56;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatters = context.formatters;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A fixed height instead of IntrinsicHeight, which costs an extra
        // layout pass on every row.
        SizedBox(
          width: 1,
          height: 48,
          child: ColoredBox(color: context.colors.surfaceMuted),
        ),
        // Its own small padding: the card's 12 on top of a 48 button would
        // make a counter card much taller than the others.
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s4,
          ),
          child: SizedBox(
            width: _width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  container: true,
                  label: formatters.digits(
                    l10n.habitProgressSemantics(item.count, item.target),
                  ),
                  excludeSemantics: true,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${formatters.number(item.count)} / '
                      '${formatters.number(item.target)}',
                      maxLines: 1,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: item.canDecrement ? onDecrement : null,
                  tooltip: l10n.removeOne,
                  style: IconButton.styleFrom(
                    minimumSize: const Size.square(48),
                  ),
                  icon: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const new({required this.item});

  final TodayItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatters = context.formatters;
    final colors = context.colors;
    final caption = context.textTheme.bodySmall;
    final streak = item.streak;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.habit.name,
          style: context.textTheme.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // A Wrap, not a Row: with a big font the parts drop to a new line
        // instead of overflowing.
        Wrap(
          spacing: AppSpacing.s8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              streak.current > 0
                  ? formatters.digits(l10n.streakCurrent(streak.current))
                  : l10n.streakStart,
              style: caption,
            ),
            if (item.isStreakAtRisk)
              Text(
                l10n.streakAtRisk,
                style: caption?.copyWith(
                  color: colors.textAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (streak.freezesAvailable > 0)
              _FreezeBadge(count: streak.freezesAvailable),
          ],
        ),
      ],
    );
  }
}

class _FreezeBadge extends StatelessWidget {
  const new({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final formatters = context.formatters;

    return Semantics(
      container: true,
      label: formatters.digits(context.l10n.streakFreezesAvailable(count)),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.ac_unit, size: 14, color: context.colors.textSecondary),
          AppSpacing.s4.hSpace,
          Text(formatters.number(count), style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}
