import 'package:material_ui/material_ui.dart';

// Raw tile bases (Light values). Dark tiles blend these at 20% over surface.
const _orangeTile = Color(0xFFFED6B9);
const _greenTile = Color(0xFFDFE9B4);
const _pinkTile = Color(0xFFFFDDF6);
const _darkSurface = Color(0xFF2A1E19);

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const new
  ({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.dayPill,
    required this.primary,
    required this.onPrimary,
    required this.primaryDark,
    required this.onPrimaryDark,
    required this.ink,
    required this.onInk,
    required this.reminderCard,
    required this.textPrimary,
    required this.textSecondary,
    required this.textAccent,
    required this.tileOrange,
    required this.tileGreen,
    required this.tilePink,
    required this.barBrown,
    required this.barRust,
    required this.barOlive,
    required this.barPink,
    required this.barTrack,
    required this.checkRing,
    required this.error,
    required this.onError,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color dayPill;
  final Color primary;
  final Color onPrimary;
  final Color primaryDark;
  final Color onPrimaryDark;
  final Color ink;
  final Color onInk;
  final Color reminderCard;
  final Color textPrimary;
  final Color textSecondary;
  final Color textAccent;
  final Color tileOrange;
  final Color tileGreen;
  final Color tilePink;
  final Color barBrown;
  final Color barRust;
  final Color barOlive;
  final Color barPink;
  final Color barTrack;
  final Color checkRing;
  final Color error;
  final Color onError;

  static const light = AppColors(
    background: Color(0xFFF8F2EF),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEFE6E1), // provisional
    dayPill: Color(0xFFFAFAFA),
    primary: Color(0xFFFF7617),
    onPrimary: Color(0xFF3B1F14), // accessible: 5.64:1 on primary
    primaryDark: Color(0xFF652E06),
    onPrimaryDark: Color(0xFFFFFFFF),
    ink: Color(0xFF292D32),
    onInk: Color(0xFFFFFFFF),
    reminderCard: Color(0xFFFFD7B9),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF545454),
    textAccent: Color(0xFFB8500F), // accessible orange text: 4.52:1
    tileOrange: _orangeTile,
    tileGreen: _greenTile,
    tilePink: _pinkTile,
    barBrown: Color(0xFF513632),
    barRust: Color(0xFF98460E),
    barOlive: Color(0xFF8BA231),
    barPink: Color(0xFFE586CA),
    barTrack: Color(0xFFEFE6E1),
    // Design value was 0xFFC9C4C0 (~1.8:1, fails 3:1 for UI components).
    checkRing: Color(0xFF8C8580),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
  );

  // Not const: tile colors are computed with Color.alphaBlend.
  static final dark = AppColors(
    background: const Color(0xFF1C1411),
    surface: _darkSurface,
    surfaceMuted: const Color(0xFF36271F),
    dayPill: const Color(0xFF36271F), // provisional
    primary: const Color(0xFFFF7617),
    onPrimary: const Color(0xFF1C1411),
    primaryDark: const Color(0xFFFF7617), // provisional, revisit in S6 (FAB)
    onPrimaryDark: const Color(0xFF1C1411),
    ink: const Color(0xFFF8F2EF), // inverted: dark ink is invisible on dark bg
    onInk: const Color(0xFF1C1411),
    reminderCard: const Color(0xFF3D2418),
    textPrimary: const Color(0xFFF8F2EF),
    textSecondary: const Color(0xFFA89A92),
    textAccent: const Color(0xFFFF7617),
    tileOrange: Color.alphaBlend(
      _orangeTile.withValues(alpha: 0.2),
      _darkSurface,
    ),
    tileGreen: Color.alphaBlend(
      _greenTile.withValues(alpha: 0.2),
      _darkSurface,
    ),
    tilePink: Color.alphaBlend(_pinkTile.withValues(alpha: 0.2), _darkSurface),
    barBrown: const Color(0xFF8C6A5F), // lightened to reach 3:1 on surface
    barRust: const Color(0xFFC2631F), // lightened to reach 3:1 on surface
    barOlive: const Color(0xFF8BA231),
    barPink: const Color(0xFFE586CA),
    barTrack: const Color(0xFF36271F),
    checkRing: const Color(0xFF7A6B63),
    error: const Color(0xFFFF8A80),
    onError: const Color(0xFF1C1411),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? dayPill,
    Color? primary,
    Color? onPrimary,
    Color? primaryDark,
    Color? onPrimaryDark,
    Color? ink,
    Color? onInk,
    Color? reminderCard,
    Color? textPrimary,
    Color? textSecondary,
    Color? textAccent,
    Color? tileOrange,
    Color? tileGreen,
    Color? tilePink,
    Color? barBrown,
    Color? barRust,
    Color? barOlive,
    Color? barPink,
    Color? barTrack,
    Color? checkRing,
    Color? error,
    Color? onError,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      dayPill: dayPill ?? this.dayPill,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryDark: primaryDark ?? this.primaryDark,
      onPrimaryDark: onPrimaryDark ?? this.onPrimaryDark,
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
      reminderCard: reminderCard ?? this.reminderCard,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textAccent: textAccent ?? this.textAccent,
      tileOrange: tileOrange ?? this.tileOrange,
      tileGreen: tileGreen ?? this.tileGreen,
      tilePink: tilePink ?? this.tilePink,
      barBrown: barBrown ?? this.barBrown,
      barRust: barRust ?? this.barRust,
      barOlive: barOlive ?? this.barOlive,
      barPink: barPink ?? this.barPink,
      barTrack: barTrack ?? this.barTrack,
      checkRing: checkRing ?? this.checkRing,
      error: error ?? this.error,
      onError: onError ?? this.onError,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      dayPill: Color.lerp(dayPill, other.dayPill, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      onPrimaryDark: Color.lerp(onPrimaryDark, other.onPrimaryDark, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      onInk: Color.lerp(onInk, other.onInk, t)!,
      reminderCard: Color.lerp(reminderCard, other.reminderCard, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textAccent: Color.lerp(textAccent, other.textAccent, t)!,
      tileOrange: Color.lerp(tileOrange, other.tileOrange, t)!,
      tileGreen: Color.lerp(tileGreen, other.tileGreen, t)!,
      tilePink: Color.lerp(tilePink, other.tilePink, t)!,
      barBrown: Color.lerp(barBrown, other.barBrown, t)!,
      barRust: Color.lerp(barRust, other.barRust, t)!,
      barOlive: Color.lerp(barOlive, other.barOlive, t)!,
      barPink: Color.lerp(barPink, other.barPink, t)!,
      barTrack: Color.lerp(barTrack, other.barTrack, t)!,
      checkRing: Color.lerp(checkRing, other.checkRing, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
    );
  }
}
