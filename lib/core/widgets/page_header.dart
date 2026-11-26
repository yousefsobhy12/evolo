import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// The large page title of the design, with an optional widget at the end
/// (a close button, an avatar) and an optional line under it (a date).
///
/// It takes the place of an `AppBar`, so it does not handle the status bar:
/// the page puts it inside a `SafeArea`.
class PageHeader extends StatelessWidget {
  const new({required this.title, this.subtitle, this.trailing, super.key});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.screen,
        vertical: AppSpacing.s16,
      ),
      child: Row(
        children: [
          // No maxLines: a long title or a big system font wraps to more
          // lines instead of being cut.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: context.textTheme.headlineLarge),
              ),
              if (subtitle != null) ...[
                AppSpacing.s4.vSpace,
                Text(subtitle!, style: context.textTheme.bodyMedium),
              ],
            ],
          ).expanded(),
          if (trailing != null) ...[AppSpacing.s12.hSpace, trailing!],
        ],
      ),
    );
  }
}
