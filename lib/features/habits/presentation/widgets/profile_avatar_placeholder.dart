import 'package:evolo/core/extensions/extensions.dart';
import 'package:material_ui/material_ui.dart';

/// TEMPORARY: stands where the user's avatar will be once the local profile
/// exists (S11).
///
/// It is decoration only: not a button, and hidden from screen readers.
class ProfileAvatarPlaceholder extends StatelessWidget {
  const new({super.key});

  static const double size = 60;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.tileOrange,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person_outline, size: 32, color: colors.onTileOrange),
      ),
    );
  }
}
