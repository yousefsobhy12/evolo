import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/theme/app_radius.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/presentation/utils/habit_color_style.dart';
import 'package:evolo/features/habits/presentation/utils/habit_icons.dart';
import 'package:material_ui/material_ui.dart';

/// A habit's icon on its colored 48x48 tile. Decoration: the habit's name is
/// always next to it, so screen readers skip it.
class HabitIconTile extends StatelessWidget {
  const new({required this.iconKey, required this.color, super.key});

  final String iconKey;
  final HabitColor color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ExcludeSemantics(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.tileBackground(colors),
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
        child: Icon(
          HabitIcons.resolve(iconKey),
          size: 24,
          color: color.tileForeground(colors),
        ),
      ),
    );
  }
}
