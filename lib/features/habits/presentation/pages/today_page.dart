import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/core/widgets/max_content_width.dart';
import 'package:evolo/core/widgets/state_message.dart';
import 'package:evolo/dev/dev_menu_button.dart';
import 'package:evolo/features/habits/presentation/cubit/today_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:evolo/features/habits/presentation/widgets/day_strip.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class TodayPage extends StatefulWidget {
  const new({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The phone can sleep past midnight. When the app comes back, the cubit
    // checks whether "today" moved.
    _lifecycle = AppLifecycleListener(
      onResume: () => context.read<TodayCubit>().refreshToday(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final cubit = context.read<TodayCubit>();

    return BlocListener<TodayCubit, TodayState>(
      listenWhen: (previous, current) =>
          current.actionFailure != null &&
          previous.actionFailure != current.actionFailure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.actionErrorMessage)));
        // Shown once, so clear it. Otherwise the same failure would not
        // trigger the listener again next time.
        cubit.dismissActionFailure();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.todayTitle),
          actions: [
            BlocSelector<TodayCubit, TodayState, bool>(
              selector: (state) => state.selectedDay != state.today,
              builder: (context, showBackToToday) {
                if (!showBackToToday) return const SizedBox.shrink();
                return TextButton(
                  onPressed: cubit.goToToday,
                  child: Text(l10n.backToToday),
                );
              },
            ),
            if (kDebugMode) const DevMenuButton(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.newHabit),
          tooltip: l10n.addHabit,
          backgroundColor: colors.primaryDark,
          foregroundColor: colors.onPrimaryDark,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
        body: MaxContentWidth(
          child: BlocBuilder<TodayCubit, TodayState>(
            builder: (context, state) => Column(
              children: [
                DayStrip(
                  days: state.days,
                  title: context.formatters.monthYear(
                    state.selectedDay.toDateTime(),
                  ),
                  canGoPrevious: state.canGoPrevious,
                  canGoNext: state.canGoNext,
                  onSelectDay: cubit.selectDay,
                  onPrevious: cubit.previousWeek,
                  onNext: cubit.nextWeek,
                ),
                AppSpacing.s16.vSpace,
                _Content(state: state).expanded(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Below the strip: exactly one of the four states.
class _Content extends StatelessWidget {
  const new({required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<TodayCubit>();

    switch (state.status) {
      case TodayStatus.loading:
        return Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.loading),
        );
      case TodayStatus.failure:
        return StateMessage(
          icon: Icons.error_outline,
          iconColor: context.colorScheme.error,
          title: l10n.loadErrorTitle,
          message: l10n.loadErrorMessage,
          action: FilledButton(onPressed: cubit.retry, child: Text(l10n.retry)),
        );
      case TodayStatus.success:
        return switch (state.emptyReason) {
          TodayEmptyReason.noHabits => StateMessage(
            icon: Icons.check_circle_outline,
            title: l10n.emptyNoHabitsTitle,
            message: l10n.emptyNoHabitsMessage,
            action: FilledButton(
              onPressed: () => context.push(AppRoutes.newHabit),
              child: Text(l10n.emptyNoHabitsAction),
            ),
          ),
          TodayEmptyReason.nothingDue => StateMessage(
            icon: Icons.bedtime_outlined,
            title: l10n.emptyNothingDueTitle,
            message: l10n.emptyNothingDueMessage,
          ),
          null => _HabitList(state: state),
        };
    }
  }
}

class _HabitList extends StatelessWidget {
  const new({required this.state});

  final TodayState state;

  /// Room for the FAB (56) + its margins, so the last card is never hidden.
  static const double _fabClearance = 88;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TodayCubit>();
    final items = state.items;

    return ListView.separated(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.screen,
        end: AppSpacing.screen,
        bottom: _fabClearance,
      ),
      // Index 0 is the section heading, the habits come after it.
      itemCount: items.length + 1,
      separatorBuilder: (_, index) =>
          (index == 0 ? AppSpacing.s12 : AppSpacing.taskCardGap).vSpace,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Semantics(
            header: true,
            child: Text(
              context.l10n.todayDailyRoutine,
              style: context.textTheme.headlineMedium,
            ),
          );
        }
        final item = items[index - 1];
        return HabitCard(
          key: ValueKey(item.habit.id),
          item: item,
          onTap: () => cubit.tapCheck(item),
          onDecrement: () => cubit.decrement(item),
        );
      },
    );
  }
}
