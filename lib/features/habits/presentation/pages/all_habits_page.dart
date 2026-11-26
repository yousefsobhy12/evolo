import 'dart:async';

import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/core/widgets/circle_icon_button.dart';
import 'package:evolo/core/widgets/max_content_width.dart';
import 'package:evolo/core/widgets/page_header.dart';
import 'package:evolo/core/widgets/page_status_bar.dart';
import 'package:evolo/core/widgets/state_message.dart';
import 'package:evolo/features/habits/presentation/cubit/all_habits_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/all_habits_state.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_summary_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Every habit, whatever its days are, so any of them can be edited at any
/// time. Today only lists what is due on the selected day.
class AllHabitsPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return PageStatusBar(
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: MaxContentWidth(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: PageHeader(
                    title: context.l10n.allHabitsTitle,
                    trailing: CircleIconButton(
                      icon: Icons.close,
                      tooltip: MaterialLocalizations.of(context)
                          .closeButtonTooltip,
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go(AppRoutes.today),
                    ),
                  ),
                ),
                BlocBuilder<AllHabitsCubit, AllHabitsState>(
                  builder: _content,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Exactly one of the four states. Always a sliver.
  Widget _content(BuildContext context, AllHabitsState state) {
    final l10n = context.l10n;

    switch (state.status) {
      case AllHabitsStatus.loading:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(semanticsLabel: l10n.loading),
          ),
        );
      case AllHabitsStatus.failure:
        return SliverStateMessage(
          icon: Icons.error_outline,
          iconColor: context.colorScheme.error,
          title: l10n.loadErrorTitle,
          message: l10n.loadErrorMessage,
          action: FilledButton(
            onPressed: context.read<AllHabitsCubit>().retry,
            child: Text(l10n.retry),
          ),
        );
      case AllHabitsStatus.success:
        final habits = state.habits;
        if (habits.isEmpty) {
          return SliverStateMessage(
            icon: Icons.check_circle_outline,
            title: l10n.emptyNoHabitsTitle,
            message: l10n.emptyNoHabitsMessage,
            action: FilledButton(
              onPressed: () => unawaited(context.push(AppRoutes.newHabit)),
              child: Text(l10n.emptyNoHabitsAction),
            ),
          );
        }
        return SliverPadding(
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.screen,
            end: AppSpacing.screen,
            // The SafeArea leaves the bottom open.
            bottom: AppSpacing.s24 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          sliver: SliverList.separated(
            itemCount: habits.length,
            separatorBuilder: (_, _) => AppSpacing.taskCardGap.vSpace,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return HabitSummaryCard(
                key: ValueKey(habit.id),
                habit: habit,
                onPressed: () =>
                    unawaited(context.push(AppRoutes.editHabit(habit.id))),
              );
            },
          ),
        );
    }
  }
}
