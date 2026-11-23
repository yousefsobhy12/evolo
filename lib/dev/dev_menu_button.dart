import 'dart:async';

import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/core/di/injection.dart';
import 'package:evolo/core/l10n/locale_cubit.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/theme/theme_mode_cubit.dart';
import 'package:evolo/dev/debug_seeder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// TEMPORARY, debug builds only (the caller wraps it in `kDebugMode`).
///
/// Until Settings (S11) exists this is how to flip language and theme from
/// the Today screen, and how to fill the app with sample data. Text is
/// hard-coded English on purpose: it never ships.
class DevMenuButton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VoidCallback>(
      tooltip: 'Dev menu',
      icon: const Icon(Icons.more_vert),
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: context.read<LocaleCubit>().toggle,
          child: const Text('Switch language'),
        ),
        PopupMenuItem(
          value: context.read<ThemeModeCubit>().toggle,
          child: const Text('Switch theme'),
        ),
        PopupMenuItem(
          value: () => context.push(AppRoutes.themeShowcase),
          child: const Text('Theme showcase'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: () => _seed(context),
          child: const Text('Seed sample habits'),
        ),
        PopupMenuItem(
          value: () => _clear(context),
          child: const Text('Clear all habits'),
        ),
      ],
    );
  }

  // Both actions start a Future from a plain callback, so they wrap it in
  // `unawaited` and read what they need from `context` before any await.
  static void _seed(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final arabic = context.read<LocaleCubit>().state.languageCode == 'ar';
    unawaited(
      _report(messenger, () async {
        final count = await DebugSeeder(getIt<AppDatabase>())
            .seed(arabic: arabic);
        return 'Seeded $count sample habits (replaced the old ones)';
      }),
    );
  }

  static void _clear(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    unawaited(
      _report(messenger, () async {
        final count = await DebugSeeder(getIt<AppDatabase>()).clearAll();
        return 'Deleted $count habits';
      }),
    );
  }

  static Future<void> _report(
    ScaffoldMessengerState messenger,
    Future<String> Function() task,
  ) async {
    String message;
    try {
      message = await task();
    } on Object catch (error) {
      message = 'Failed: $error';
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
