import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_radius.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/presentation/utils/habit_labels.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_icon_tile.dart';
import 'package:material_ui/material_ui.dart';

/// The "Icon and color" field: a preview of the habit's tile and the two
/// chosen names. Pressing it opens the sheet with both pickers.
class HabitAppearanceField extends StatelessWidget {
  const new({
    required this.iconKey,
    required this.color,
    required this.onPressed,
    super.key,
  });

  final String iconKey;
  final HabitColor color;

  /// Null disables the field.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final separator = Localizations.localeOf(context).languageCode == 'ar'
        ? '، '
        : ', ';
    final summary =
        '${habitIconName(l10n, iconKey)}$separator'
        '${habitColorName(l10n, color)}';

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: '${l10n.habitAppearanceLabel}: $summary',
      excludeSemantics: true,
      onTap: onPressed,
      child: Opacity(
        opacity: onPressed != null ? 1 : 0.5,
        child: Material(
          color: colors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: InkWell(
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.s12),
                child: Row(
                  children: [
                    HabitIconTile(iconKey: iconKey, color: color),
                    AppSpacing.s12.hSpace,
                    Text(
                      summary,
                      style: context.textTheme.bodyMedium,
                    ).expanded(),
                    // A down arrow reads the same in both directions.
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
