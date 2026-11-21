import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:evolo/features/habits/data/datasources/habit_schedule_converter.dart';
import 'package:evolo/features/habits/data/datasources/habits_dao.dart';
import 'package:evolo/features/habits/data/datasources/habits_table.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Habits], daos: [HabitsDao])
class AppDatabase extends _$AppDatabase {
  /// Takes the executor as an argument so tests can pass an in-memory one.
  new(super.e);

  /// The real, on-disk database used by the app.
  factory open() {
    return AppDatabase(
      driftDatabase(
        name: 'evolo',
        native: const DriftNativeOptions(
          databaseDirectory: getApplicationSupportDirectory,
        ),
      ),
    );
  }

  @override
  int get schemaVersion => 1;
}
