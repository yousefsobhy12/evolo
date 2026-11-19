import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class RouteErrorPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screen,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: context.colorScheme.error,
              ),
              AppSpacing.s16.vSpace,
              Text(
                context.l10n.pageNotFoundTitle,
                style: context.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              AppSpacing.s8.vSpace,
              Text(
                context.l10n.pageNotFoundMessage,
                textAlign: TextAlign.center,
              ),
              AppSpacing.s24.vSpace,
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(context.l10n.goHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
