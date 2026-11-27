import 'dart:async';

import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/repositories/completion_repository.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/stats/domain/entities/stats_period.dart';
import 'package:evolo/features/stats/domain/usecases/get_habit_stats.dart';
import 'package:evolo/features/stats/presentation/cubit/stats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

/// Drives the statistics screen.
///
/// It only wires things together: two repository streams (habits and every
/// completion) in, one [StatsState] out. The counting rules live in
/// `GetHabitStats`.
class StatsCubit extends Cubit<StatsState> {
  new(
    this._habitRepository,
    this._completionRepository,
    this._getHabitStats, {
    this._weekStart = Weekday.saturday,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       _today = CalendarDay.fromDateTime((now ?? DateTime.now)()),
       super(const StatsState()) {
    _subscribe();
  }

  final HabitRepository _habitRepository;
  final CompletionRepository _completionRepository;
  final GetHabitStats _getHabitStats;
  final Weekday _weekStart;
  final DateTime Function() _now;

  CalendarDay _today;
  StatsPeriod _period = StatsPeriod.week;

  // Last value of each stream. Null means "not delivered yet".
  List<Habit>? _habits;
  List<Completion>? _completions;
  Failure? _habitsFailure;
  Failure? _completionsFailure;

  bool _isRetrying = false;
  bool _isClosing = false;

  StreamSubscription<Either<Failure, List<Habit>>>? _habitsSubscription;
  StreamSubscription<Either<Failure, List<Completion>>>?
  _completionsSubscription;

  void selectPeriod(StatsPeriod period) {
    if (period == _period) return;
    _period = period;
    _publish();
  }

  /// Call when the app returns to the foreground: the day may have changed
  /// while it was in the background.
  void refreshToday() {
    final now = CalendarDay.fromDateTime(_now());
    if (now == _today) return;
    _today = now;
    _publish();
  }

  /// Subscribes again after a load failure. Extra calls while one is running
  /// are ignored, so there is never a second pair of subscriptions.
  Future<void> retry() async {
    if (_isRetrying) return;
    _isRetrying = true;
    await _cancelSubscriptions();
    _isRetrying = false;
    if (_isClosing) return;
    _habits = null;
    _completions = null;
    _habitsFailure = null;
    _completionsFailure = null;
    _publish();
    _subscribe();
  }

  @override
  Future<void> close() async {
    _isClosing = true;
    await _cancelSubscriptions();
    return await super.close();
  }

  void _subscribe() {
    _habitsSubscription = _habitRepository.watchHabits().listen(_onHabits);
    _completionsSubscription = _completionRepository.watchAll().listen(
      _onCompletions,
    );
  }

  Future<void> _cancelSubscriptions() async {
    await _habitsSubscription?.cancel();
    await _completionsSubscription?.cancel();
    _habitsSubscription = null;
    _completionsSubscription = null;
  }

  void _onHabits(Either<Failure, List<Habit>> result) {
    result.fold<void>((failure) => _habitsFailure = failure, (habits) {
      _habitsFailure = null;
      _habits = habits;
    });
    _publish();
  }

  void _onCompletions(Either<Failure, List<Completion>> result) {
    result.fold<void>((failure) => _completionsFailure = failure, (
      completions,
    ) {
      _completionsFailure = null;
      _completions = completions;
    });
    _publish();
  }

  /// Builds the whole state from the private fields.
  void _publish() {
    if (isClosed) return;

    final next = _buildState();
    // Bloc skips equal states, except the very first emit, which always goes
    // out. This stops a repeated Loading state while one stream is pending.
    if (next == state) return;
    emit(next);
  }

  StatsState _buildState() {
    final failure = _habitsFailure ?? _completionsFailure;
    if (failure != null) {
      return StatsState(
        period: _period,
        status: StatsStatus.failure,
        failure: failure,
      );
    }

    final habits = _habits;
    final completions = _completions;
    if (habits == null || completions == null) {
      return StatsState(period: _period);
    }

    return StatsState(
      period: _period,
      status: StatsStatus.success,
      report: _getHabitStats(
        habits: habits,
        completions: completions,
        period: _period,
        today: _today,
        firstDay: _weekStart,
      ),
    );
  }
}
