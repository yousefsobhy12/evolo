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

  /// Every row, grouped by habit and oldest day first inside each habit.
  /// The two-column order is total (the key is `(habitId, day)`), so the
  /// list never flickers between emissions.
  Stream<List<CompletionRow>> watchAll() {
    final query = select(completions)
      ..orderBy([
        (t) => OrderingTerm.asc(t.habitId),
        (t) => OrderingTerm.asc(t.day),
      ]);
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
      final habit = await _findHabit(habitId);
      if (habit == null) return false;

      await _store(
        habitId: habitId,
        day: day,
        count: count,
        target: habit.dailyTarget,
      );
      return true;
    });
  }

  /// Returns false when the habit does not exist (nothing is written).
  ///
  /// Reads the current count and writes the new one inside a single
  /// transaction, so concurrent adjustments are applied one after the other
  /// instead of overwriting each other. The count is clamped at 0, and when
  /// it does not change nothing is written.
  Future<bool> adjustCount({
    required String habitId,
    required CalendarDay day,
    required int delta,
  }) {
    return transaction(() async {
      final habit = await _findHabit(habitId);
      if (habit == null) return false;

      final existing =
          await (select(completions)..where(
                (t) => t.habitId.equals(habitId) & t.day.equalsValue(day),
              ))
              .getSingleOrNull();
      final current = existing?.count ?? 0;
      final sum = current + delta;
      final next = sum < 0 ? 0 : sum;

      if (next != current) {
        await _store(
          habitId: habitId,
          day: day,
          count: next,
          target: habit.dailyTarget,
        );
      }
      return true;
    });
  }

  /// Rewrites the target snapshot of one day's row and keeps its count.
  /// Returns how many rows changed (0 when the habit has no row that day).
  ///
  /// Used when a habit's `dailyTarget` is edited: today is judged by the
  /// habit's current target while it is on screen, but once it becomes a
  /// past day it is judged by this snapshot. Without the rewrite, a day the
  /// user saw as finished could turn into a broken streak at midnight.
  Future<int> updateTargetSnapshot({
    required String habitId,
    required CalendarDay day,
    required int target,
  }) {
    return (update(completions)
          ..where((t) => t.habitId.equals(habitId) & t.day.equalsValue(day)))
        .write(CompletionsCompanion(target: Value(target)));
  }

  Future<HabitRow?> _findHabit(String habitId) {
    return (select(
      habits,
    )..where((t) => t.id.equals(habitId))).getSingleOrNull();
  }

  /// Must run inside the caller's transaction. `count == 0` removes the row.
  Future<void> _store({
    required String habitId,
    required CalendarDay day,
    required int count,
    required int target,
  }) async {
    if (count == 0) {
      await (delete(
        completions,
      )..where((t) => t.habitId.equals(habitId) & t.day.equalsValue(day))).go();
    } else {
      await into(completions).insertOnConflictUpdate(
        CompletionsCompanion.insert(
          habitId: habitId,
          day: day,
          count: count,
          target: target,
        ),
      );
    }
  }
}
