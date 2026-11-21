import 'package:drift/drift.dart';
import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/features/habits/data/datasources/habits_table.dart';

part 'habits_dao.g.dart';

@DriftAccessor(tables: [Habits])
class HabitsDao extends DatabaseAccessor<AppDatabase> with _$HabitsDaoMixin {
  new(super.attachedDatabase);

  /// Oldest first. `id` breaks ties because `createdAt` has second
  /// precision, so the order never flickers between emissions.
  Stream<List<HabitRow>> watchAll() {
    final query = select(habits)
      ..orderBy([
        (t) => OrderingTerm.asc(t.createdAt),
        (t) => OrderingTerm.asc(t.id),
      ]);
    return query.watch();
  }

  Future<HabitRow?> findById(String id) {
    return (select(habits)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Returns the row as stored in the database.
  Future<HabitRow> insertHabit(HabitsCompanion entry) {
    return into(habits).insertReturning(entry);
  }

  /// Returns how many rows changed (0 means the id does not exist).
  Future<int> updateById(String id, HabitsCompanion changes) {
    return (update(habits)..where((t) => t.id.equals(id))).write(changes);
  }

  Future<int> deleteById(String id) {
    return (delete(habits)..where((t) => t.id.equals(id))).go();
  }
}
