import 'dart:math' as math;

import 'package:evolo/core/extensions/extensions.dart';
import 'package:material_ui/material_ui.dart';

/// The round button beside a habit card, on the start side.
///
/// - Goal of 1: an empty ring, which fills with a check when done.
/// - Goal above 1 ([isCounter]): a progress ring with a "+" inside, which
///   fills with a check when the goal is reached.
///
/// It only draws what it is told. The rules (what a tap does) live in
/// `TodayItem`, and the screen passes [onPressed] already decided
/// (null = disabled).
class HabitCheckButton extends StatelessWidget {
  const new({
    required this.progress,
    required this.isCompleted,
    required this.isCounter,
    required this.semanticLabel,
    required this.onPressed,
    super.key,
  });

  /// 0..1, how much of the goal is done.
  final double progress;
  final bool isCompleted;
  final bool isCounter;

  /// Read by screen readers and shown as the tooltip-free label.
  final String semanticLabel;

  /// Null disables the button (for example a finished counter).
  final VoidCallback? onPressed;

  // Looks are fixed (like the other tokens): 36 drawn inside a 48 tap target.
  static const double _size = 36;
  static const double _tapTarget = 48;
  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onPressed,
      child: InkResponse(
        onTap: onPressed,
        radius: _tapTarget / 2,
        child: SizedBox.square(
          dimension: _tapTarget,
          child: Center(
            child: SizedBox.square(
              dimension: _size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The circle sits on the screen background, so it brings
                  // its own surface. First in the stack: under the ring.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                    ),
                    child: const SizedBox.square(dimension: _size),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: isCounter ? progress : 0),
                    duration: _duration,
                    builder: (context, value, _) => CustomPaint(
                      size: const Size.square(_size),
                      painter: _RingPainter(
                        progress: value,
                        trackColor: colors.checkRing,
                        arcColor: colors.primary,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: _duration,
                    width: _size,
                    height: _size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? colors.primary : Colors.transparent,
                    ),
                  ),
                  if (isCompleted)
                    Icon(Icons.check, size: 20, color: colors.onPrimary)
                  else if (isCounter)
                    Icon(Icons.add, size: 20, color: colors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const new({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
  });

  static const double _stroke = 2.5;

  final double progress;
  final Color trackColor;
  final Color arcColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Inset by half the stroke so the line stays inside the box.
    final rect = (Offset.zero & size).deflate(_stroke / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = trackColor;
    canvas.drawOval(rect, track);

    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = arcColor;
    // Starts at 12 o'clock and goes clockwise.
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.arcColor != arcColor;
}
