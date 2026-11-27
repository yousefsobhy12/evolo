import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/features/stats/domain/entities/stats_period.dart';
import 'package:material_ui/material_ui.dart';

/// Switches the statistics between this week and this month.
///
/// A `SegmentedButton`, so the selected state, focus and the "one of two"
/// announcement for screen readers come from Material. Only the colors are
/// ours: the selected segment uses `ink`, the same as the selected day on
/// Today.
class StatsPeriodToggle extends StatelessWidget {
  const new({required this.period, required this.onChanged, super.key});

  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.screen,
      ),
      child: SegmentedButton<StatsPeriod>(
        // Both segments share the full width.
        expandedInsets: EdgeInsets.zero,
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: StatsPeriod.week,
            label: Text(l10n.statsPeriodWeek),
          ),
          ButtonSegment(
            value: StatsPeriod.month,
            label: Text(l10n.statsPeriodMonth),
          ),
        ],
        selected: {period},
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: SegmentedButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
          selectedBackgroundColor: colors.ink,
          selectedForegroundColor: colors.onInk,
          side: BorderSide.none,
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}
