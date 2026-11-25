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

  /// Bounds for [dailyTarget]. The Today card adds one per tap, so a bigger
  /// goal is not practical to complete. The limits live here (not only in the
  /// form's stepper) so the repository enforces them too.
  static const int minDailyTarget = 1;
  static const int maxDailyTarget = 99;

  /// How long [name] is for the length rule. [validateName] uses this same
  /// measure, so a character counter in the UI can never disagree with the
  /// rule. Surrounding whitespace is not counted (the repository stores the
  /// name trimmed). It counts UTF-16 code units, so an emoji counts as 2.
  static int nameLength(String name) => name.trim().length;

  static ValidationReason? validateName(String name) {
    final length = nameLength(name);
    if (length == 0) return ValidationReason.nameEmpty;
    if (length > maxNameLength) return ValidationReason.nameTooLong;
    return null;
  }

  static ValidationReason? validateDailyTarget(int dailyTarget) {
    if (dailyTarget < minDailyTarget) return ValidationReason.invalidTarget;
    if (dailyTarget > maxDailyTarget) return ValidationReason.targetTooHigh;
    return null;
  }

  /// Takes the raw days (not a [HabitSchedule]) because a schedule cannot
  /// be built from an empty set, and the form needs to report exactly that.
  static ValidationReason? validateDays(Set<Weekday> days) {
    if (days.isEmpty) return ValidationReason.noDaysSelected;
    return null;
  }

  /// Returns why the fields are invalid, or null when they are fine. The
  /// first problem wins, in a fixed order: name, target, days. The form uses
  /// the per-field methods above to show every error at once; the rules are
  /// the same ones.
  static ValidationReason? validate({
    required String name,
    required int dailyTarget,
    required HabitSchedule schedule,
  }) {
    return validateName(name) ??
        validateDailyTarget(dailyTarget) ??
        validateDays(schedule.days);
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
