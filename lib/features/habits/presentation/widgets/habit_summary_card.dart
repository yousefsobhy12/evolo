import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_radius.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/presentation/utils/schedule_summary.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_icon_tile.dart';
import 'package:material_ui/material_ui.dart';

/// A habit on the "All habits" list: what it is and when it is due. Pressing
/// it opens the habit for editing. Completing belongs to Today.
class HabitSummaryCard extends StatelessWidget {
  const new({required this.habit, required this.onPressed, super.key});

  final Habit habit;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final caption = context.textTheme.bodySmall;

    return Semantics(
      button: true,
      onTapHint: l10n.editHabitTitle,
      child: Material(
        color: colors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.s12),
              child: Row(
                children: [
                  HabitIconTile(iconKey: habit.iconKey, color: habit.color),
                  AppSpacing.s12.hSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        habit.name,
                        style: context.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        scheduleSummary(context, habit.schedule.days),
                        style: caption,
                      ),
                      Text(
                        context.formatters.digits(
                          l10n.habitTargetSummary(habit.dailyTarget),
                        ),
                        style: caption,
                      ),
                    ],
                  ).expanded(),
                  AppSpacing.s8.hSpace,
                  // A pencil has no direction to mirror in Arabic.
                  ExcludeSemantics(
                    child: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
