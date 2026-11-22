import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';

final class IsHabitDue {
  const new();

  bool call(Habit habit, CalendarDay day) {
    final start = CalendarDay.fromDateTime(habit.createdAt);
    return !day.isBefore(start) && habit.schedule.isDueOn(day.toDateTime());
  }
}
