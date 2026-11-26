import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/features/habits/domain/entities/today_item.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_card.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_check_button.dart';
import 'package:material_ui/material_ui.dart';

/// One row of the Today list: the check circle on the start side, the dotted
/// timeline that joins it to the circles above and below, and the habit card.
///
/// Every row draws only its own piece of the line, including the gap under
/// its card, so the pieces meet and the list can still build rows lazily.
class HabitTimelineRow extends StatelessWidget {
  const new({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.onDecrement,
    this.onEdit,
    super.key,
  });

  /// The line behind the circle. Public so tests can check what it paints.
  static const Key lineKey = ValueKey('habit-timeline-line');

  /// The width of the circle's tap target, and so of the timeline.
  static const double _rail = 48;

  final TodayItem item;

  /// No line above the first circle and none below the last one.
  final bool isFirst;
  final bool isLast;

  /// The check circle. A finished counter has nothing to add, so the button
  /// is disabled instead of silently ignoring the tap.
  final VoidCallback onTap;
  final VoidCallback onDecrement;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final gap = isLast ? 0.0 : AppSpacing.taskCardGap;

    return Stack(
      children: [
        // Directional, so the line moves to the right side in Arabic.
        PositionedDirectional(
          start: 0,
          width: _rail,
          top: 0,
          bottom: 0,
          child: CustomPaint(
            key: lineKey,
            painter: _DottedLinePainter(
              color: context.colors.checkRing,
              drawAbove: !isFirst,
              drawBelow: !isLast,
              bottomGap: gap,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: gap),
          child: Row(
            children: [
              HabitCheckButton(
                progress: item.progress,
                isCompleted: item.isCompleted,
                isCounter: item.isCounter,
                semanticLabel: _checkLabel(context),
                onPressed: item.tapDelta == 0 ? null : onTap,
              ),
              AppSpacing.s8.hSpace,
              HabitCard(
                item: item,
                onDecrement: onDecrement,
                onEdit: onEdit,
              ).expanded(),
            ],
          ),
        ),
      ],
    );
  }

  String _checkLabel(BuildContext context) {
    final l10n = context.l10n;
    final name = item.habit.name;
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

class _DottedLinePainter extends CustomPainter {
  const new({
    required this.color,
    required this.drawAbove,
    required this.drawBelow,
    required this.bottomGap,
  });

  static const double _dotRadius = 1;
  static const double _dotSpacing = 6;

  /// From the center of the circle to the first dot: the radius of the drawn
  /// circle (18) plus some air.
  static const double _clearance = 22;

  final Color color;
  final bool drawAbove;
  final bool drawBelow;

  /// The space under the card. The circle is centered on the card, not on the
  /// whole row.
  final double bottomGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final x = size.width / 2;
    final center = (size.height - bottomGap) / 2;

    // Both pieces start next to the circle and walk away from it, so the
    // dots keep the same distance from every circle.
    if (drawAbove) {
      for (var y = center - _clearance; y >= 0; y -= _dotSpacing) {
        canvas.drawCircle(Offset(x, y), _dotRadius, paint);
      }
    }
    if (drawBelow) {
      for (var y = center + _clearance; y <= size.height; y += _dotSpacing) {
        canvas.drawCircle(Offset(x, y), _dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter old) =>
      old.color != color ||
      old.drawAbove != drawAbove ||
      old.drawBelow != drawBelow ||
      old.bottomGap != bottomGap;
}
