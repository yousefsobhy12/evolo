import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

/// The calendar at the top of the habit form, drawn in code with the app
/// colors: no image file, no license, and it follows Light and Dark.
///
/// Decoration only, so screen readers skip it.
class CalendarIllustration extends StatelessWidget {
  const new({super.key});

  static const Size size = Size(132, 120);

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: size, painter: _CalendarPainter(context.colors)),
    );
  }
}

class _CalendarPainter extends CustomPainter {
  const new(this.colors);

  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint();

    // The page, a little below the top so the two rings can stick out.
    final page = RRect.fromLTRBR(
      0,
      10,
      size.width,
      size.height,
      const Radius.circular(20),
    );
    // Then its orange header, clipped by the page's rounded corners.
    canvas
      ..drawRRect(page, fill..color = colors.surface)
      ..save()
      ..clipRRect(page)
      ..drawRect(
        Rect.fromLTWH(0, 10, size.width, 30),
        fill..color = colors.primary,
      )
      ..restore();

    // The two rings.
    for (final x in [34.0, size.width - 34]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, 12), width: 10, height: 24),
          const Radius.circular(5),
        ),
        fill..color = colors.ink,
      );
    }

    // Three rows of four days. One of them is done.
    for (var row = 0; row < 3; row++) {
      for (var column = 0; column < 4; column++) {
        final center = Offset(24.0 + column * 28, 58.0 + row * 22);
        final isDone = row == 1 && column == 2;
        if (!isDone) {
          canvas.drawCircle(center, 6, fill..color = colors.tileOrange);
          continue;
        }
        canvas
          ..drawCircle(center, 11, fill..color = colors.primary)
          ..drawPath(
            Path()
              ..moveTo(center.dx - 5, center.dy)
              ..lineTo(center.dx - 1.5, center.dy + 3.5)
              ..lineTo(center.dx + 5, center.dy - 3.5),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..color = colors.onPrimary,
          );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CalendarPainter old) => old.colors != colors;
}
