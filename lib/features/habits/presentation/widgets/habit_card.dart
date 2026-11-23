import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_radius.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/features/habits/domain/entities/today_item.dart';
import 'package:evolo/features/habits/presentation/utils/habit_color_style.dart';
import 'package:evolo/features/habits/presentation/utils/habit_icons.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_check_button.dart';
import 'package:material_ui/material_ui.dart';

/// One row of the Today list.
///
/// Pure UI: it draws a [TodayItem] and reports presses. Which press changes
/// the count by how much is decided by `TodayItem` and `TodayCubit`.
class HabitCard extends StatelessWidget {
  const new({
    required this.item,
    required this.onTap,
    required this.onDecrement,
    super.key,
  });

  final TodayItem item;

  /// The check circle. A finished counter has nothing to add, so the button
  /// is disabled instead of silently ignoring the tap.
  final VoidCallback onTap;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final habit = item.habit;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: ConstrainedBox(
        // 72 from the design, but it grows with a big system font.
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            children: [
              _IconTile(item: item),
              AppSpacing.s12.hSpace,
              _Details(item: item).expanded(),
              if (item.isCounter)
                IconButton(
                  onPressed: item.canDecrement ? onDecrement : null,
                  tooltip: l10n.removeOne,
                  icon: const Icon(Icons.remove),
                ),
              HabitCheckButton(
                progress: item.progress,
                isCompleted: item.isCompleted,
                isCounter: item.isCounter,
                semanticLabel: _checkLabel(context, habit.name),
                onPressed: item.tapDelta == 0 ? null : onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _checkLabel(BuildContext context, String name) {
    final l10n = context.l10n;
    if (item.isCounter) {
      return item.isCompleted
          ? context.formatters.digits(
              l10n.habitProgressSemantics(item.count, item.target),
            )
          : l10n.addOneTo(name);
    }
    return item.isCompleted ? l10n.undoHabit(name) : l10n.completeHabit(name);
  }
}

class _IconTile extends StatelessWidget {
  const new({required this.item});

  final TodayItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final habit = item.habit;

    return ExcludeSemantics(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: habit.color.tileBackground(colors),
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
        child: Icon(
          HabitIcons.resolve(habit.iconKey),
          size: 24,
          color: habit.color.tileForeground(colors),
        ),
      ),
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
            if (item.isCounter)
              Text(
                '${formatters.number(item.count)} / '
                '${formatters.number(item.target)}',
                style: caption,
              ),
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
