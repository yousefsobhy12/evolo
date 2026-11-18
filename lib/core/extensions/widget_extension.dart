import 'package:flutter/widgets.dart';

extension WidgetLayoutX on Widget {
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) =>
      Flexible(flex: flex, fit: fit, child: this);

  Widget centered() => Center(child: this);

  Widget fullWidth() => SizedBox(width: double.infinity, child: this);

  Widget showIf({required bool condition}) =>
      condition ? this : const SizedBox.shrink();

  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  Widget paddingDirectional({
    double start = 0,
    double end = 0,
    double top = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsetsDirectional.only(
      start: start,
      end: end,
      top: top,
      bottom: bottom,
    ),
    child: this,
  );

  /// Dims the widget AND blocks touches (the old `disabled()` only dimmed).
  Widget dimmed({required bool disabled}) => IgnorePointer(
    ignoring: disabled,
    child: Opacity(opacity: disabled ? 0.5 : 1, child: this),
  );
}
