import 'package:drift/drift.dart';
import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/data/datasources/completions_table.dart';
import 'package:evolo/features/habits/data/datasources/habits_table.dart';

part 'completions_dao.g.dart';

@DriftAccessor(tables: [Completions, Habits])
class CompletionsDao extends DatabaseAccessor<AppDatabase>
    with _$CompletionsDaoMixin {
  new(super.attachedDatabase);

  /// Oldest day first. Text order is chronological order.
  Stream<List<CompletionRow>> watchForHabit(String habitId) {
    final query = select(completions)
      ..where((t) => t.habitId.equals(habitId))
      ..orderBy([(t) => OrderingTerm.asc(t.day)]);
    return query.watch();
  }

  /// `habitId` breaks ties so the order never flickers between emissions.
  Stream<List<CompletionRow>> watchOnDay(CalendarDay day) {
    final query = select(completions)
      ..where((t) => t.day.equalsValue(day))
      ..orderBy([(t) => OrderingTerm.asc(t.habitId)]);
    return query.watch();
  }

  /// Returns false when the habit does not exist (nothing is written).
  ///
  /// Reading the habit's target and writing the row happen in one
  /// transaction, so the snapshot always matches the habit at that moment.
  Future<bool> setCount({
    required String habitId,
    required CalendarDay day,
    required int count,
  }) {
    return transaction(() async {
      final habit = await (select(
        habits,
      )..where((t) => t.id.equals(habitId))).getSingleOrNull();
      if (habit == null) return false;

      if (count == 0) {
        await (delete(
              completions,
            )..where((t) => t.habitId.equals(habitId) & t.day.equalsValue(day)))
            .go();
      } else {
        await into(completions).insertOnConflictUpdate(
          CompletionsCompanion.insert(
            habitId: habitId,
            day: day,
            count: count,
            target: habit.dailyTarget,
          ),
        );
      }
      return true;
    });
  }
}
