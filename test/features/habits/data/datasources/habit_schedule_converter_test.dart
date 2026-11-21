import 'package:evolo/features/habits/data/datasources/habit_schedule_converter.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = HabitScheduleConverter();

  test('known values: monday=1, sunday=64, every day=127', () {
    expect(converter.toSql(HabitSchedule(const {Weekday.monday})), 1);
    expect(converter.toSql(HabitSchedule(const {Weekday.sunday})), 64);
    expect(converter.toSql(HabitSchedule.everyDay()), 127);
  });

  test('round-trips every possible non-empty schedule (1..127)', () {
    for (var mask = 1; mask <= 127; mask++) {
      expect(converter.toSql(converter.fromSql(mask)), mask);
    }
  });

  test('a zero mask is corrupt data and throws', () {
    expect(() => converter.fromSql(0), throwsFormatException);
  });
}
