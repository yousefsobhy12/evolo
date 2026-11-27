import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

/// Which of the four bar colors a [PillBar] uses.
///
/// The statistics page gives habit `i` the tone `forIndex(i)`, so the colors
/// repeat after four bars (decided in S8).
enum PillBarTone {
  brown,
  rust,
  olive,
  pink;

  static PillBarTone forIndex(int index) => values[index % values.length];

  Color fill(AppColors colors) => switch (this) {
    PillBarTone.brown => colors.barBrown,
    PillBarTone.rust => colors.barRust,
    PillBarTone.olive => colors.barOlive,
    PillBarTone.pink => colors.barPink,
  };

  /// Number color on the fill. Per bar and per theme, see `AppColors`.
  Color onFill(AppColors colors) => switch (this) {
    PillBarTone.brown => colors.onBarBrown,
    PillBarTone.rust => colors.onBarRust,
    PillBarTone.olive => colors.onBarOlive,
    PillBarTone.pink => colors.onBarPink,
  };
}

/// A vertical pill: a hatched track with a colored fill rising from the
/// bottom, and the value written as a number.
///
/// It only draws. It does not know what the number means: the page passes
/// [percent] (for the height), [label] (already formatted for the locale) and
/// [semanticsLabel] (already translated).
///
/// Where the number goes:
/// - the fill is tall enough: inside it, at the top, in the bar's own text
///   color;
/// - otherwise (a low value, 0, or no data): right above the fill, on the
///   hatched track, in `textPrimary`.
/// The number is never hidden and the fill height is never faked.
class PillBar extends StatelessWidget {
  const new({
    required this.percent,
    required this.label,
    required this.semanticsLabel,
    required this.tone,
    this.width = 82,
    this.height = 200,
    super.key,
  });

  /// 0..100 (clamped). `null` means "no counted days": an empty fill.
  final int? percent;

  /// The text shown on the bar, e.g. `80%` or `—`.
  final String label;

  /// What a screen reader says for the whole bar (the number is hidden from it
  /// so it is not read twice).
  final String semanticsLabel;

  final PillBarTone tone;
  final double width;
  final double height;

  // Inside the fill the top is rounded, so the number keeps away from the
  // curve. Outside, it only needs a small gap above the fill.
  static const _insidePadding = 12.0;
  static const _outsideGap = 6.0;
  static const _sidePadding = 8.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textTheme.titleMedium ?? const TextStyle();

    final fraction = (percent ?? 0).clamp(0, 100) / 100;
    final fillHeight = height * fraction;

    // An estimate of one text line. It follows the system text scale so a
    // bigger font needs a taller fill before the number moves inside.
    final labelHeight =
        MediaQuery.textScalerOf(context).scale(style.fontSize ?? 17) *
        (style.height ?? 1.3);
    final fitsInside =
        percent != null && fillHeight >= labelHeight + 2 * _insidePadding;

    final numberStyle = style.copyWith(
      color: fitsInside ? tone.onFill(colors) : colors.textPrimary,
    );
    // FittedBox centers the number horizontally inside the tight width it gets
    // from the Positioned, and shrinks it if a long label would not fit.
    final number = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(label, style: numberStyle, maxLines: 1),
    );

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(width / 2),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _HatchPainter(
                      background: colors.barTrack,
                      stripe: colors.barTrackStripe,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: fillHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tone.fill(colors),
                      borderRadius: BorderRadius.circular(width / 2),
                    ),
                  ),
                ),
                if (fitsInside)
                  Positioned(
                    left: _sidePadding,
                    right: _sidePadding,
                    top: height - fillHeight + _insidePadding,
                    child: number,
                  )
                else
                  Positioned(
                    left: _sidePadding,
                    right: _sidePadding,
                    bottom: fillHeight + _outsideGap,
                    child: number,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the track: a flat color with diagonal lines.
class _HatchPainter extends CustomPainter {
  const new({required this.background, required this.stripe});

  final Color background;
  final Color stripe;

  static const _spacing = 8.0;
  static const _strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final line = Paint()
      ..color = stripe
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;
    // Each line goes from bottom-left to top-right at 45 degrees. Starting at
    // -height makes the lines also cover the bottom-right corner.
    for (var x = -size.height; x < size.width; x += _spacing) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), line);
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) =>
      oldDelegate.background != background || oldDelegate.stripe != stripe;
}
