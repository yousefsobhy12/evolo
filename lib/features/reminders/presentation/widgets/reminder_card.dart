import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/theme/app_radius.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// The warm card that invites the user to set a reminder.
///
/// Built in S6 so the design is ready, but NOT shown on the Today screen yet:
/// the button has nothing to open until the reminders feature exists (S10).
/// It takes its texts as parameters, so it stays a plain widget with no
/// knowledge of l10n or of where it is mounted.
class ReminderCard extends StatelessWidget {
  const new({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.reminderCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.reminder),
      ),
      child: ConstrainedBox(
        // ~148 from the design; grows with a big system font.
        constraints: const BoxConstraints(minHeight: 148),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: context.textTheme.titleMedium,
                        ),
                      ),
                      AppSpacing.s4.vSpace,
                      Text(
                        message,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ).expanded(),
                  AppSpacing.s12.hSpace,
                  ExcludeSemantics(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: colors.textAccent,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.s16.vSpace,
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primaryDark,
                  foregroundColor: colors.onPrimaryDark,
                  minimumSize: const Size(64, 48),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
