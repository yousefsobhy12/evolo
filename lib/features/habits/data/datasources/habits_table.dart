import 'package:drift/drift.dart';
import 'package:evolo/features/habits/data/datasources/habit_schedule_converter.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';

/// The generated row class is `HabitRow`, so it never clashes with the
/// domain `Habit` entity.
@DataClassName('HabitRow')
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconKey => text()();
  TextColumn get color => textEnum<HabitColor>()();

  late final Column<int> dailyTarget = integer().check(
    dailyTarget.isBiggerOrEqualValue(1),
  )();

  IntColumn get schedule => integer().map(const HabitScheduleConverter())();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
