import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/habits_injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  test('registerHabitsFeature resolves a working HabitRepository', () async {
    final getIt = GetIt.asNewInstance();
    addTearDown(getIt.reset);
    getIt.registerSingleton<AppDatabase>(
      AppDatabase(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      ),
      dispose: (database) => database.close(),
    );

    registerHabitsFeature(getIt);

    final repository = getIt<HabitRepository>();
    expect(repository, isA<HabitRepositoryImpl>());
    final first = await repository.watchHabits().first;
    expect(first.getOrElse((_) => fail('expected Right')), isEmpty);
  });
}
