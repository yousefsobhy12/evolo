import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/core/widgets/max_content_width.dart';
import 'package:evolo/core/widgets/page_header.dart';
import 'package:evolo/core/widgets/page_status_bar.dart';
import 'package:evolo/core/widgets/state_message.dart';
import 'package:evolo/dev/dev_menu_button.dart';
import 'package:evolo/features/habits/presentation/cubit/today_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:evolo/features/habits/presentation/utils/greeting.dart';
import 'package:evolo/features/habits/presentation/widgets/day_strip.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_timeline_row.dart';
import 'package:evolo/features/habits/presentation/widgets/profile_avatar_placeholder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class TodayPage extends StatefulWidget {
  const new({this.now = DateTime.now, super.key});

  /// The clock behind the greeting. Tests pass a fixed one.
  final DateTime Function() now;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

/// Room for the FAB (56) + its margins, so nothing stays hidden under it.
const double _fabClearance = 88;

class _TodayPageState extends State<TodayPage> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The phone can sleep past midnight. When the app comes back, the cubit
    // checks whether "today" moved.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        context.read<TodayCubit>().refreshToday();
        // The greeting may be out of date even when the day is the same, and
        // then the cubit emits nothing.
        setState(() {});
      },
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
      child: PageStatusBar(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push(AppRoutes.newHabit),
            tooltip: l10n.addHabit,
            backgroundColor: colors.primaryDark,
            foregroundColor: colors.onPrimaryDark,
            // The soft shadow of the design: it lifts the button off the
            // cards that scroll under it.
            elevation: 6,
            highlightElevation: 8,
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
            bottom: false,
            child: MaxContentWidth(
              child: BlocBuilder<TodayCubit, TodayState>(
                // One scroll view for the whole page: the header and the
                // strip leave the screen together with the list.
                builder: (context, state) => CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(state: state, now: widget.now()),
                          DayStrip(
                            days: state.days,
                            canGoPrevious: state.canGoPrevious,
                            canGoNext: state.canGoNext,
                            onSelectDay: cubit.selectDay,
                            onPrevious: cubit.previousWeek,
                            onNext: cubit.nextWeek,
                          ),
                          if (state.selectedDay != state.today)
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed: cubit.goToToday,
                                style: TextButton.styleFrom(
                                  foregroundColor: colors.textAccent,
                                  minimumSize: const Size(48, 48),
                                ),
                                child: Text(l10n.backToToday),
                              ).paddingSymmetric(horizontal: AppSpacing.s12),
                            ),
                          AppSpacing.s16.vSpace,
                        ],
                      ),
                    ),
                    _Content(state: state),
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

/// The greeting, the date of the day being shown, and the avatar.
class _Header extends StatelessWidget {
  const new({required this.state, required this.now});

  final TodayState state;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PageHeader(
      title: switch (Greeting.at(now)) {
        Greeting.morning => l10n.greetingMorning,
        Greeting.afternoon => l10n.greetingAfternoon,
        Greeting.evening => l10n.greetingEvening,
      },
      // The selected day, not always today: the strip has no month title, so
      // this line is what tells which month is on screen.
      subtitle: context.formatters.fullDate(state.selectedDay.toDateTime()),
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [if (kDebugMode) DevMenuButton(), ProfileAvatarPlaceholder()],
      ),
    );
  }
}

/// Below the strip: exactly one of the four states. Always a sliver.
class _Content extends StatelessWidget {
  const new({required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<TodayCubit>();

    switch (state.status) {
      case TodayStatus.loading:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(semanticsLabel: l10n.loading),
          ),
        );
      case TodayStatus.failure:
        return SliverStateMessage(
          bottomPadding: _fabClearance,
          icon: Icons.error_outline,
          iconColor: context.colorScheme.error,
          title: l10n.loadErrorTitle,
          message: l10n.loadErrorMessage,
          action: FilledButton(onPressed: cubit.retry, child: Text(l10n.retry)),
        );
      case TodayStatus.success:
        return switch (state.emptyReason) {
          TodayEmptyReason.noHabits => SliverStateMessage(
            bottomPadding: _fabClearance,
            icon: Icons.check_circle_outline,
            title: l10n.emptyNoHabitsTitle,
            message: l10n.emptyNoHabitsMessage,
            action: FilledButton(
              onPressed: () => context.push(AppRoutes.newHabit),
              child: Text(l10n.emptyNoHabitsAction),
            ),
          ),
          TodayEmptyReason.nothingDue => SliverStateMessage(
            bottomPadding: _fabClearance,
            icon: Icons.bedtime_outlined,
            title: l10n.emptyNothingDueTitle,
            message: l10n.emptyNothingDueMessage,
            // Without a list there is no heading, and this is the way to the
            // habits of the other days.
            action: FilledButton(
              onPressed: () => context.push(AppRoutes.allHabits),
              child: Text(l10n.seeAll),
            ),
          ),
          null => _HabitList(state: state),
        };
    }
  }
}

/// "Daily routine" with the way to every habit at the end of the line.
class _ListHeading extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.s4),
      // A Wrap: with a big font the button drops to its own line.
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.s8,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.todayDailyRoutine,
                style: context.textTheme.headlineMedium,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.allHabits),
              style: TextButton.styleFrom(
                foregroundColor: context.colors.textAccent,
                minimumSize: const Size(48, 48),
              ),
              child: Text(l10n.seeAll),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitList extends StatelessWidget {
  const new({required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TodayCubit>();
    final items = state.items;

    return SliverPadding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.screen,
        end: AppSpacing.screen,
        // The SafeArea leaves the bottom open, so the system navigation
        // area is added here.
        bottom: _fabClearance + MediaQuery.viewPaddingOf(context).bottom,
      ),
      sliver: SliverList.builder(
        // Index 0 is the section heading, the habits come after it.
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _ListHeading();
          }
          final item = items[index - 1];
          // No separators: each row owns the gap under it, so the timeline
          // has no holes.
          return HabitTimelineRow(
            key: ValueKey(item.habit.id),
            item: item,
            isFirst: index == 1,
            isLast: index == items.length,
            onTap: () => cubit.tapCheck(item),
            onDecrement: () => cubit.decrement(item),
            onEdit: () => context.push(AppRoutes.editHabit(item.habit.id)),
          );
        },
      ),
    );
  }
}
