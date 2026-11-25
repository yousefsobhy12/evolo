import 'dart:async';

import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/entities/today_item.dart';
import 'package:evolo/features/habits/domain/repositories/completion_repository.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/domain/usecases/get_today_items.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

/// Drives the Today screen.
///
/// It only wires things together: two repository streams (habits and every
/// completion) in, one [TodayState] out. The real rules live in pure
/// usecases (`GetTodayItems`, `GetStreakStatus`) and in `TodayItem`.
///
/// The raw data and the selection are kept in private fields and the whole
/// state is rebuilt from them on every change, so there is no `copyWith` and
/// no way for two fields to drift out of sync.
class TodayCubit extends Cubit<TodayState> {
  new(
    this._habitRepository,
    this._completionRepository,
    this._getTodayItems, {
    Weekday weekStart = Weekday.saturday,
    DateTime Function()? now,
  }) : _weekStart = weekStart,
       _now = now ?? DateTime.now,
       _today = _todayFrom(now),
       _selectedDay = _todayFrom(now),
       super(
         TodayState(
           today: _todayFrom(now),
           selectedDay: _todayFrom(now),
           weekStart: weekStart,
         ),
       ) {
    _subscribe();
  }

  final HabitRepository _habitRepository;
  final CompletionRepository _completionRepository;
  final GetTodayItems _getTodayItems;
  final Weekday _weekStart;
  final DateTime Function() _now;

  CalendarDay _today;
  CalendarDay _selectedDay;
  CalendarDay? _firstSelectableDay;

  // Last value of each stream. Null means "not delivered yet".
  List<Habit>? _habits;
  List<Completion>? _completions;
  Failure? _habitsFailure;
  Failure? _completionsFailure;
  Failure? _actionFailure;

  List<TodayItem> _items = const [];

  StreamSubscription<Either<Failure, List<Habit>>>? _habitsSubscription;
  StreamSubscription<Either<Failure, List<Completion>>>?
  _completionsSubscription;

  static CalendarDay _todayFrom(DateTime Function()? now) =>
      CalendarDay.fromDateTime((now ?? DateTime.now)());

  // --- Day strip -----------------------------------------------------------

  /// Opens [day]. Ignored for the future and for days before the first habit.
  void selectDay(CalendarDay day) {
    final first = _firstSelectableDay;
    if (day.isAfter(_today)) return;
    if (first != null && day.isBefore(first)) return;
    if (day == _selectedDay) return;
    _moveSelectionTo(day);
  }

  /// Same weekday one week earlier (or the first selectable day).
  void previousWeek() {
    if (!state.canGoPrevious) return;
    _moveSelectionTo(_selectedDay.addDays(-7));
  }

  /// Same weekday one week later (or today, whichever comes first).
  void nextWeek() {
    if (!state.canGoNext) return;
    _moveSelectionTo(_selectedDay.addDays(7));
  }

  void goToToday() {
    if (_selectedDay == _today) return;
    _moveSelectionTo(_today);
  }

  /// Call when the app returns to the foreground: the day may have changed
  /// while it was in the background. If the user was looking at today, the
  /// selection follows to the new today; a past day they opened stays put.
  void refreshToday() {
    final now = CalendarDay.fromDateTime(_now());
    if (now == _today) return;
    final followToday = _selectedDay == _today;
    _today = now;
    if (followToday) _selectedDay = now;
    _rebuild();
    _publish();
  }

  // --- Completing habits ---------------------------------------------------

  /// A tap on the check circle (rules in `TodayItem.tapDelta`).
  Future<void> tapCheck(TodayItem item) => _adjust(item, item.tapDelta);

  /// A press on the minus button (rules in `TodayItem.decrementDelta`).
  Future<void> decrement(TodayItem item) => _adjust(item, item.decrementDelta);

  /// Call after the screen has shown [TodayState.actionFailure].
  void dismissActionFailure() {
    if (_actionFailure == null) return;
    _actionFailure = null;
    _publish();
  }

  /// Subscribes again after a load failure.
  Future<void> retry() async {
    await _cancelSubscriptions();
    _habits = null;
    _completions = null;
    _habitsFailure = null;
    _completionsFailure = null;
    _items = const [];
    _publish();
    _subscribe();
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return await super.close();
  }

  // --- Internals -----------------------------------------------------------

  Future<void> _adjust(TodayItem item, int delta) async {
    if (delta == 0) return;
    final result = await _completionRepository.adjustCount(
      habitId: item.habit.id,
      day: _selectedDay,
      delta: delta,
    );
    // Success needs nothing: the completions stream emits the new count.
    result.fold<void>((failure) {
      // The habit was deleted while this tap was on its way. The habits
      // stream is about to remove the card, so an error would only confuse.
      if (failure is NotFoundFailure) return;
      _actionFailure = failure;
      _publish();
    }, (_) {});
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
    _rebuild();
    _publish();
  }

  void _onCompletions(Either<Failure, List<Completion>> result) {
    result.fold<void>((failure) => _completionsFailure = failure, (
      completions,
    ) {
      _completionsFailure = null;
      _completions = completions;
    });
    _rebuild();
    _publish();
  }

  void _moveSelectionTo(CalendarDay day) {
    _selectedDay = day;
    _rebuild();
    _publish();
  }

  /// Recomputes everything derived from the raw data and the selection.
  void _rebuild() {
    final habits = _habits;
    final completions = _completions;
    if (habits != null && completions != null) {
      _firstSelectableDay = _firstSelectableFor(habits);
    }
    _clampSelection();
    if (habits == null || completions == null) return;
    _items = _getTodayItems(
      habits: habits,
      completions: completions,
      day: _selectedDay,
      today: _today,
    );
  }

  /// The day the oldest habit was created, or today when there are none.
  /// Never later than today (a clock set back must not lock the strip).
  CalendarDay _firstSelectableFor(List<Habit> habits) {
    if (habits.isEmpty) return _today;
    final earliest = habits
        .map((habit) => CalendarDay.fromDateTime(habit.createdAt))
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return earliest.isAfter(_today) ? _today : earliest;
  }

  /// Keeps the selection inside [first selectable day, today].
  void _clampSelection() {
    var day = _selectedDay;
    if (day.isAfter(_today)) day = _today;
    final first = _firstSelectableDay;
    if (first != null && day.isBefore(first)) day = first;
    _selectedDay = day;
  }

  void _publish() {
    if (isClosed) return;

    final habits = _habits;
    final completions = _completions;
    final ready = habits != null && completions != null;
    final failure = _habitsFailure ?? _completionsFailure;

    final TodayStatus status;
    if (failure != null) {
      status = TodayStatus.failure;
    } else if (ready) {
      status = TodayStatus.success;
    } else {
      status = TodayStatus.loading;
    }

    final next = TodayState(
      today: _today,
      selectedDay: _selectedDay,
      weekStart: _weekStart,
      firstSelectableDay: _firstSelectableDay,
      status: status,
      items: status == TodayStatus.success ? _items : const [],
      hasAnyHabit: habits != null && completions != null && habits.isNotEmpty,
      failure: failure,
      actionFailure: _actionFailure,
    );
    // Bloc skips equal states, except the very first emit, which always goes
    // out. Without this check, "habits arrived but completions did not yet"
    // would publish a Loading state identical to the initial one.
    if (next == state) return;
    emit(next);
  }
}
