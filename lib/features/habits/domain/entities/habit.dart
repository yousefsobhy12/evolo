import 'package:equatable/equatable.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';

class Habit extends Equatable {
  const new({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.color,
    required this.dailyTarget,
    required this.schedule,
    required this.createdAt,
  });

  static const int maxNameLength = 50;

  /// Returns why the fields are invalid, or null when they are fine.
  /// Used by the repository now and by the add/edit form (S7) later.
  static ValidationReason? validate({
    required String name,
    required int dailyTarget,
    required HabitSchedule schedule,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return ValidationReason.nameEmpty;
    if (trimmed.length > maxNameLength) return ValidationReason.nameTooLong;
    if (dailyTarget < 1) return ValidationReason.invalidTarget;
    if (schedule.days.isEmpty) return ValidationReason.noDaysSelected;
    return null;
  }

  final String id;
  final String name;

  /// Key into the UI's icon registry (not an IconData code point).
  final String iconKey;
  final HabitColor color;

  /// Completions needed per day. 1 means a simple check-off habit.
  final int dailyTarget;
  final HabitSchedule schedule;
  final DateTime createdAt;

  /// `id` and `createdAt` are identity: they cannot be changed here.
  Habit copyWith({
    String? name,
    String? iconKey,
    HabitColor? color,
    int? dailyTarget,
    HabitSchedule? schedule,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      color: color ?? this.color,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    iconKey,
    color,
    dailyTarget,
    schedule,
    createdAt,
  ];
}
