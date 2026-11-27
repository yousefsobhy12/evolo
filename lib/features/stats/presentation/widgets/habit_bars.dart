import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/features/stats/presentation/widgets/pill_bar.dart';
import 'package:material_ui/material_ui.dart';

/// What one bar needs: the habit's name and its completion percent.
///
/// Plain values on purpose, so this widget does not depend on the domain.
class HabitBarData {
  const new({required this.name, required this.percent});

  final String name;

  /// 0..100, or null when no day was counted.
  final int? percent;
}

/// One [PillBar] per habit, side by side, with the habit name under each.
///
/// It always scrolls horizontally: four bars are already wider than a 360
/// phone, and with fewer bars there is simply nothing to scroll. Habit `i`
/// gets the tone `i % 4`, in the order the habits were given.
class HabitBars extends StatelessWidget {
  const new({required this.bars, super.key});

  final List<HabitBarData> bars;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Directional: the scroll starts at the start edge, also in Arabic.
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.screen,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, bar) in bars.indexed) ...[
            if (index > 0) AppSpacing.s12.hSpace,
            _BarColumn(bar: bar, tone: PillBarTone.forIndex(index)),
          ],
        ],
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const new({required this.bar, required this.tone});

  final HabitBarData bar;
  final PillBarTone tone;

  // The same width as a PillBar, so the name wraps under its bar.
  static const double _width = 82;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percent = bar.percent;
    final value = percent == null
        ? l10n.statsNoCountedDays
        : context.formatters.percent(percent / 100);

    return SizedBox(
      width: _width,
      child: Column(
        children: [
          PillBar(
            percent: percent,
            label: percent == null ? '—' : value,
            semanticsLabel: l10n.statsBarSemantics(bar.name, value),
            tone: tone,
          ),
          AppSpacing.s8.vSpace,
          // The bar already speaks the name, so this text is not read again.
          ExcludeSemantics(
            child: Text(
              bar.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
