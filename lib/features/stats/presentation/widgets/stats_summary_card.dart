import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// The three numbers of the period: completion rate, best streak, total
/// check-ins.
///
/// It takes plain values, not the domain report: the page decides where they
/// come from, and this widget only decides how they look.
class StatsSummaryCard extends StatelessWidget {
  const new({
    required this.percent,
    required this.bestStreak,
    required this.totalCheckIns,
    super.key,
  });

  /// 0..100. Null means no counted day: shown as a dash.
  final int? percent;

  /// Longest streak of any habit, over all time (not only this period).
  final int bestStreak;

  final int totalCheckIns;

  // TODO(S8): replace with the card radius token once its name is known.
  static const double _radius = 24;

  // Above this system text scale the three columns are too narrow for their
  // labels, so they stack.
  static const double _stackAtTextScale = 1.2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatters = context.formatters;
    final colors = context.colors;
    final rate = percent;

    final stats = [
      _Stat(
        label: l10n.statsCompletionRate,
        value: rate == null ? '—' : formatters.percent(rate / 100),
        valueSemantics: rate == null ? l10n.statsNoCountedDays : null,
      ),
      _Stat(
        label: l10n.statsBestStreak,
        value: formatters.number(bestStreak),
        caption: l10n.statsBestStreakCaption(bestStreak),
      ),
      _Stat(
        label: l10n.statsTotalCheckIns,
        value: formatters.number(totalCheckIns),
      ),
    ];

    final isStacked =
        MediaQuery.textScalerOf(context).scale(1) > _stackAtTextScale;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.screen,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.s16),
          child: isStacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (index, stat) in stats.indexed) ...[
                      if (index > 0) AppSpacing.s16.vSpace,
                      stat,
                    ],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (index, stat) in stats.indexed) ...[
                      if (index > 0) AppSpacing.s12.hSpace,
                      Expanded(child: stat),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    this.valueSemantics,
    this.caption,
  });

  final String label;
  final String value;

  /// What a screen reader says instead of [value], for example when the value
  /// is a dash.
  final String? valueSemantics;

  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final secondary = TextStyle(color: colors.textSecondary);

    // One spoken item: "Completion rate, 67%".
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textTheme.bodyMedium?.merge(secondary)),
          AppSpacing.s4.vSpace,
          Semantics(
            label: valueSemantics,
            excludeSemantics: valueSemantics != null,
            child: Text(
              value,
              // `textAccent`, not `primary`: orange text on white needs the
              // darker orange to reach 4.5:1.
              style: context.textTheme.headlineMedium?.copyWith(
                color: colors.textAccent,
              ),
            ),
          ),
          if (caption != null)
            Text(
              caption!,
              style: context.textTheme.bodySmall?.merge(secondary),
            ),
        ],
      ),
    );
  }
}
