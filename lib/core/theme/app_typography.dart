import 'package:evolo/core/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the app [TextTheme] from the design scale (section 3.3).
/// The font family depends on the locale: Outfit for Latin, Readex Pro for Arabic.
abstract final class AppTypography {
  static const _latinFamily = 'Outfit';
  static const _arabicFamily = 'ReadexPro';

  static TextTheme textTheme({
    required Locale locale,
    required Brightness brightness,
    required AppColors colors,
  }) {
    final isArabic = locale.languageCode == 'ar';
    final family = isArabic ? _arabicFamily : _latinFamily;
    // Outfit has no Arabic glyphs, so each family falls back to the other.
    final fallback = [if (isArabic) _latinFamily else _arabicFamily];
    // PROVISIONAL: Arabic glyphs need more vertical room. Tune in the showcase.
    final height = isArabic ? 1.5 : 1.3;

    TextStyle style(double size, FontWeight weight, {Color? color}) {
      return TextStyle(
        fontFamily: family,
        fontFamilyFallback: fallback,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: 0, // never track Arabic text
        color: color ?? colors.textPrimary,
      );
    }

    // Start from Flutter's defaults so unused slots still get our font/color,
    // then override the slots we use.
    final base = ThemeData(brightness: brightness).textTheme.apply(
      fontFamily: family,
      fontFamilyFallback: fallback,
      displayColor: colors.textPrimary,
      bodyColor: colors.textPrimary,
    );

    return base.merge(
      TextTheme(
        headlineLarge: style(32, FontWeight.w500), // H1
        headlineMedium: style(22, FontWeight.w500), // H2
        titleMedium: style(17, FontWeight.w500), // Title
        bodyLarge: style(15, FontWeight.w400),
        bodyMedium: style(15, FontWeight.w400), // Body (default Text style)
        bodySmall: style(
          13,
          FontWeight.w400,
          color: colors.textSecondary,
        ), // Caption
        labelLarge: style(17, FontWeight.w600), // Button
      ),
    );
  }
}
