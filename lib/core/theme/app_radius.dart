/// Corner radii from design section 3.4.
/// Uniform radii are RTL-safe; asymmetric ones must use BorderRadiusDirectional.
abstract final class AppRadius {
  static const double tile = 14;
  static const double card = 20;
  static const double reminder = 24;

  /// PROVISIONAL: not specified in the design, verify against the shot.
  static const double input = 16;

  /// Full pill (buttons, bars). Use with a large value or StadiumBorder.
  static const double pill = 999;
}
