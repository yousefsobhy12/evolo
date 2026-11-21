import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() => db.close());

  test('inserts a habit row and reads it back with typed columns', () async {
    await db
        .into(db.habits)
        .insert(
          HabitsCompanion.insert(
            id: 'h1',
            name: 'Read',
            iconKey: 'book',
            color: HabitColor.orange,
            dailyTarget: 1,
            schedule: HabitSchedule(const {Weekday.monday, Weekday.friday}),
            createdAt: DateTime(2026, 11, 20),
          ),
        );

    final row = await db.select(db.habits).getSingle();

    expect(row.name, 'Read');
    expect(row.color, HabitColor.orange);
    expect(row.schedule, HabitSchedule(const {Weekday.friday, Weekday.monday}));
  });

  test('the database rejects a daily target below 1', () async {
    final insert = db
        .into(db.habits)
        .insert(
          HabitsCompanion.insert(
            id: 'h2',
            name: 'Bad',
            iconKey: 'book',
            color: HabitColor.green,
            dailyTarget: 0,
            schedule: HabitSchedule.everyDay(),
            createdAt: DateTime(2026, 11, 20),
          ),
        );

    await expectLater(insert, throwsA(anything));
  });
}
