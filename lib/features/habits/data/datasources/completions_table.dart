import 'package:drift/drift.dart';
import 'package:evolo/features/habits/data/datasources/calendar_day_converter.dart';
import 'package:evolo/features/habits/data/datasources/habits_table.dart';

/// One row per habit per day, only while `count > 0`.
@DataClassName('CompletionRow')
class Completions extends Table {
  /// Deleting a habit deletes its completions (needs foreign keys ON,
  /// see `AppDatabase.migration`).
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();

  TextColumn get day => text().map(const CalendarDayConverter())();

  late final Column<int> count = integer().check(
    count.isBiggerOrEqualValue(1),
  )();

  /// The habit's `dailyTarget` when this row was last written.
  late final Column<int> target = integer().check(
    target.isBiggerOrEqualValue(1),
  )();

  @override
  Set<Column<Object>> get primaryKey => {habitId, day};
}
