import 'package:evolo/core/theme/app_colors.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:material_ui/material_ui.dart';

/// Turns the stored [HabitColor] into theme tokens.
///
/// The DB stores only the name (`orange`, `green`, `pink`); the actual colors
/// come from [AppColors], so Dark mode gets its own tile and icon colors.
extension HabitColorStyle on HabitColor {
  /// Background of the habit's icon tile.
  Color tileBackground(AppColors colors) => switch (this) {
    HabitColor.orange => colors.tileOrange,
    HabitColor.green => colors.tileGreen,
    HabitColor.pink => colors.tilePink,
  };

  /// Color of the icon drawn on [tileBackground].
  Color tileForeground(AppColors colors) => switch (this) {
    HabitColor.orange => colors.onTileOrange,
    HabitColor.green => colors.onTileGreen,
    HabitColor.pink => colors.onTilePink,
  };
}
