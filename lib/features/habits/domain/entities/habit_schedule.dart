import 'package:equatable/equatable.dart';

/// ISO weekdays, same order as [DateTime.weekday] (monday = 1 ... sunday = 7).
/// The week's first day is a UI concern (Egypt starts on Saturday).
enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static Weekday fromDateTime(DateTime date) => values[date.weekday - 1];
}

/// The days a habit is due. "Daily" is simply all seven days.
class HabitSchedule extends Equatable {
  new(Set<Weekday> days)
    : assert(days.isNotEmpty, 'A schedule needs at least one day'),
      days = Set.unmodifiable(days);

  factory everyDay() => HabitSchedule(Weekday.values.toSet());

  final Set<Weekday> days;

  bool get isEveryDay => days.length == Weekday.values.length;

  /// Pass a local date: day boundaries follow the user's time zone.
  bool isDueOn(DateTime date) => days.contains(Weekday.fromDateTime(date));

  // Sorted list so equality never depends on Set ordering/implementation.
  @override
  List<Object?> get props => [(days.map((d) => d.index).toList()..sort())];
}
