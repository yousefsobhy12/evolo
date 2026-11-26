import 'package:evolo/core/theme/app_colors.dart';
import 'package:evolo/core/theme/app_radius.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/core/theme/app_typography.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  static ThemeData light(Locale locale) => _build(
    locale: locale,
    brightness: Brightness.light,
    colors: AppColors.light,
  );

  static ThemeData dark(Locale locale) => _build(
    locale: locale,
    brightness: Brightness.dark,
    colors: AppColors.dark,
  );

  static ThemeData _build({
    required Locale locale,
    required Brightness brightness,
    required AppColors colors,
  }) {
    final textTheme = AppTypography.textTheme(
      locale: locale,
      brightness: brightness,
      colors: colors,
    );

    // AppColors is the single source of truth. ColorScheme is derived from it
    // so stock Material widgets pick up the right colors automatically.
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.ink,
      onSecondary: colors.onInk,
      tertiary: colors.primaryDark,
      onTertiary: colors.onPrimaryDark,
      error: colors.error,
      onError: colors.onError,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      surfaceContainerHighest: colors.surfaceMuted,
      outline: colors.outline,
      outlineVariant: colors.surfaceMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
      ),
      dividerTheme: DividerThemeData(
        color: colors.surfaceMuted,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          minimumSize: const Size(64, 56),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: _inputTheme(colors, textTheme),
    );
  }

  static InputDecorationTheme _inputTheme(
    AppColors colors,
    TextTheme textTheme,
  ) {
    OutlineInputBorder border([BorderSide side = BorderSide.none]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: side,
      );
    }

    OutlineInputBorder line(Color color, double width) =>
        border(BorderSide(color: color, width: width));

    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      constraints: const BoxConstraints(minHeight: 56),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s16,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
      labelStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
      errorStyle: textTheme.bodySmall?.copyWith(color: colors.error),
      prefixIconColor: colors.textSecondary,
      suffixIconColor: colors.textSecondary,
      // No line at rest, as in the design: the white field and the label
      // above it mark the input. A line appears for focus and errors only.
      border: border(),
      enabledBorder: border(),
      disabledBorder: border(),
      // textAccent (not primary): orange on white is 2.67:1, a focus
      // indicator needs 3:1. textAccent is 4.52:1 in Light.
      focusedBorder: line(colors.textAccent, 2),
      errorBorder: line(colors.error, 1),
      focusedErrorBorder: line(colors.error, 2),
    );
  }
}
