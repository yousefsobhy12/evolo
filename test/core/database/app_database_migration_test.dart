import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1 -> v2 keeps habits, adds completions and cascade works', () async {
    // A database exactly as S4 (schemaVersion 1) left it on a device.
    final db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(
          setup: (rawDb) {
            rawDb
              ..execute('''
                CREATE TABLE "habits" (
                  "id" TEXT NOT NULL,
                  "name" TEXT NOT NULL,
                  "icon_key" TEXT NOT NULL,
                  "color" TEXT NOT NULL,
                  "daily_target" INTEGER NOT NULL
                    CHECK ("daily_target" >= 1),
                  "schedule" INTEGER NOT NULL,
                  "created_at" INTEGER NOT NULL,
                  PRIMARY KEY ("id")
                )
              ''')
              ..execute(
                'INSERT INTO habits '
                '(id, name, icon_key, color, daily_target, schedule, created_at) '
                "VALUES ('h1', 'Read', 'book', 'orange', 2, 127, 1700000000)",
              )
              ..execute('PRAGMA user_version = 1');
          },
        ),
        closeStreamsSynchronously: true,
      ),
    );
    addTearDown(db.close);

    final habit = await db.select(db.habits).getSingle();
    expect(habit.name, 'Read');
    expect(habit.dailyTarget, 2);
    expect(habit.schedule, HabitSchedule.everyDay());

    final written = await db.completionsDao.setCount(
      habitId: 'h1',
      day: CalendarDay(2026, 11, 20),
      count: 2,
    );
    expect(written, isTrue);
    expect((await db.select(db.completions).getSingle()).target, 2);

    await db.habitsDao.deleteById('h1');
    expect(await db.select(db.completions).get(), isEmpty);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 2);
  });
}
