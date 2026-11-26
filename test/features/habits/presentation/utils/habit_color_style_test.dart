import 'package:evolo/core/theme/app_colors.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/presentation/utils/habit_color_style.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/contrast_ratio.dart';

void main() {
  final themes = <String, AppColors>{
    'light': AppColors.light,
    'dark': AppColors.dark,
  };

  test('each color maps to its own tile token', () {
    const colors = AppColors.light;

    expect(HabitColor.orange.tileBackground(colors), colors.tileOrange);
    expect(HabitColor.green.tileBackground(colors), colors.tileGreen);
    expect(HabitColor.pink.tileBackground(colors), colors.tilePink);
    expect(HabitColor.orange.tileForeground(colors), colors.onTileOrange);
    expect(HabitColor.green.tileForeground(colors), colors.onTileGreen);
    expect(HabitColor.pink.tileForeground(colors), colors.onTilePink);
  });

  themes.forEach((name, colors) {
    group(name, () {
      test('the three tiles are different colors', () {
        final backgrounds = {
          for (final color in HabitColor.values) color.tileBackground(colors),
        };

        expect(backgrounds, hasLength(HabitColor.values.length));
      });

      for (final color in HabitColor.values) {
        test('the ${color.name} icon is clearly visible on its tile', () {
          final ratio = contrastRatio(
            color.tileForeground(colors),
            color.tileBackground(colors),
          );

          // An icon is non-text content, so WCAG asks for 3:1 (4.5 is the
          // text threshold).
          expect(ratio, greaterThanOrEqualTo(3));
        });
      }
    });
  });
}
