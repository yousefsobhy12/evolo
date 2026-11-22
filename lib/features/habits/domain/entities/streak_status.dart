import 'package:equatable/equatable.dart';
import 'package:evolo/core/utils/calendar_day.dart';

final class StreakStatus extends Equatable {
  const new({
    required this.current,
    required this.longest,
    required this.freezesAvailable,
    required this.frozenDays,
    required this.isTodayAtRisk,
  });

  static const empty = StreakStatus(
    current: 0,
    longest: 0,
    freezesAvailable: 0,
    frozenDays: [],
    isTodayAtRisk: false,
  );

  /// Consecutive due days completed, ending at the last due day (today is
  /// counted only once it is completed).
  final int current;

  /// Always `>= current`.
  final int longest;

  /// Freezes in stock right now.
  final int freezesAvailable;

  /// Every day in the habit's history that a freeze covered, oldest first.
  final List<CalendarDay> frozenDays;

  /// Today is a due day and is not completed yet.
  final bool isTodayAtRisk;

  @override
  List<Object> get props => [
    current,
    longest,
    freezesAvailable,
    frozenDays,
    isTodayAtRisk,
  ];
}
