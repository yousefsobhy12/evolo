import 'package:drift/drift.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';

/// Stores a [HabitSchedule] as a bitmask: bit N is set when the weekday
/// with `index == N` is due (monday = 1, tuesday = 2, ... sunday = 64).
class HabitScheduleConverter extends TypeConverter<HabitSchedule, int> {
  const new();

  @override
  HabitSchedule fromSql(int fromDb) {
    final days = {
      for (final day in Weekday.values)
        if (fromDb & (1 << day.index) != 0) day,
    };
    // A row with no days is corrupt. The repository catches this.
    if (days.isEmpty) {
      throw FormatException('Invalid schedule bitmask: $fromDb');
    }
    return HabitSchedule(days);
  }

  @override
  int toSql(HabitSchedule value) =>
      value.days.fold(0, (mask, day) => mask | (1 << day.index));
}
