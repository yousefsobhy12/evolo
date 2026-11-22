import 'package:equatable/equatable.dart';
import 'package:evolo/core/utils/calendar_day.dart';

/// How much of a habit was done on one day.
///
/// A row exists only when `count > 0`; "nothing done" is the absence of a row.
final class Completion extends Equatable {
  const new({
    required this.habitId,
    required this.day,
    required this.count,
    required this.target,
  });

  final String habitId;
  final CalendarDay day;
  final int count;

  /// The habit's `dailyTarget` at the time this row was last written. It
  /// keeps old days judged by the goal they had back then, so raising a
  /// target later does not rewrite history.
  final int target;

  @override
  List<Object> get props => [habitId, day, count, target];
}
