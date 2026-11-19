import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/l10n/locale_cubit.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// TEMPORARY (S3): replaced by the real Today screen in S6.
class HomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            onPressed: context.read<LocaleCubit>().toggle,
            icon: const Icon(Icons.translate),
            tooltip: l10n.switchLanguage,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.screen,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.homePlaceholder,
                style: context.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                AppSpacing.s24.vSpace,
                FilledButton(
                  onPressed: () => context.push(AppRoutes.themeShowcase),
                  child: Text(l10n.openThemeShowcase),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
