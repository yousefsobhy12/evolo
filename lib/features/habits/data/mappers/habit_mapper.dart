import 'package:drift/drift.dart' show Value;
import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';

extension HabitRowMapper on HabitRow {
  Habit toEntity() {
    return Habit(
      id: id,
      name: name,
      iconKey: iconKey,
      color: color,
      dailyTarget: dailyTarget,
      schedule: schedule,
      createdAt: createdAt,
    );
  }
}

extension HabitUpdateMapper on Habit {
  /// Only the editable fields: `id` and `createdAt` are never overwritten.
  HabitsCompanion toUpdateCompanion() {
    return HabitsCompanion(
      name: Value(name),
      iconKey: Value(iconKey),
      color: Value(color),
      dailyTarget: Value(dailyTarget),
      schedule: Value(schedule),
    );
  }
}
