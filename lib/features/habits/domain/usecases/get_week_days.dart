import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';

final class GetWeekDays {
  const new();

  static const daysInWeek = 7;

  List<CalendarDay> call({
    required CalendarDay day,
    required Weekday firstDay,
  }) {
    final weekday = Weekday.fromDateTime(day.toDateTime());
    final daysSinceStart = (weekday.index - firstDay.index) % daysInWeek;
    final start = day.addDays(-daysSinceStart);
    return [for (var i = 0; i < daysInWeek; i++) start.addDays(i)];
  }
}
