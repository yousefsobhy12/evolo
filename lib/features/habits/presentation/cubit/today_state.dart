import 'package:equatable/equatable.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/entities/today_item.dart';
import 'package:evolo/features/habits/domain/usecases/get_week_days.dart';

enum TodayStatus { loading, success, failure }

/// Why a successful load has nothing to list.
enum TodayEmptyReason {
  /// No habit exists at all: the screen invites the user to add one.
  noHabits,

  /// Habits exist, but none is due on the selected day (a rest day).
  nothingDue,
}

/// One cell of the day strip, ready to draw: the widget only reads flags.
final class TodayDay extends Equatable {
  const new({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isSelectable,
  });

  final CalendarDay day;
  final bool isSelected;
  final bool isToday;

  /// False for future days and for days before the first habit existed.
  final bool isSelectable;

  @override
  List<Object> get props => [day, isSelected, isToday, isSelectable];
}

/// Everything the Today screen draws. One class (not one per status) so the
/// day strip and the selection survive Loading and Error, and a retry does
/// not lose the day the user was looking at.
final class TodayState extends Equatable {
  const new({
    required this.today,
    required this.selectedDay,
    required this.weekStart,
    this.firstSelectableDay,
    this.status = TodayStatus.loading,
    this.items = const [],
    this.hasAnyHabit = false,
    this.failure,
    this.actionFailure,
  });

  static const _getWeekDays = GetWeekDays();

  final CalendarDay today;
  final CalendarDay selectedDay;

  /// The weekday the strip starts on (Saturday by default in Egypt).
  final Weekday weekStart;

  /// The earliest day the user can open: the day the oldest habit was
  /// created, or today when there are no habits. Null until the first load.
  final CalendarDay? firstSelectableDay;

  final TodayStatus status;

  /// The habits due on [selectedDay]. Empty unless [status] is success.
  final List<TodayItem> items;

  /// Whether at least one habit exists (only meaningful once loaded).
  final bool hasAnyHabit;

  /// Why loading failed. Set only when [status] is failure.
  final Failure? failure;

  /// A failed tap or minus press. The screen shows it once (a SnackBar) and
  /// then calls `dismissActionFailure`.
  final Failure? actionFailure;

  List<CalendarDay> get _week =>
      _getWeekDays(day: selectedDay, firstDay: weekStart);

  /// The seven cells of the strip for the selected day's week.
  List<TodayDay> get days => [
    for (final day in _week)
      TodayDay(
        day: day,
        isSelected: day == selectedDay,
        isToday: day == today,
        isSelectable: _isSelectable(day),
      ),
  ];

  /// Whether there is an earlier week to go back to.
  bool get canGoPrevious {
    final first = firstSelectableDay;
    return first != null && _week.first.isAfter(first);
  }

  /// Whether there is a later week (never past the week of today).
  bool get canGoNext => _week.last.isBefore(today);

  TodayEmptyReason? get emptyReason {
    if (status != TodayStatus.success || items.isNotEmpty) return null;
    return hasAnyHabit
        ? TodayEmptyReason.nothingDue
        : TodayEmptyReason.noHabits;
  }

  bool _isSelectable(CalendarDay day) {
    final first = firstSelectableDay;
    return !day.isAfter(today) && (first == null || !day.isBefore(first));
  }

  @override
  List<Object?> get props => [
    today,
    selectedDay,
    weekStart,
    firstSelectableDay,
    status,
    items,
    hasAnyHabit,
    failure,
    actionFailure,
  ];
}
