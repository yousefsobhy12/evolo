import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:fpdart/fpdart.dart';

/// Contract for habit storage. Implementations must never throw:
/// every failure comes back as a [Failure] inside `Left`.
abstract interface class HabitRepository {
  /// Emits the full list on every change. Errors arrive as `Left` values,
  /// not as stream errors, so the Cubit only needs `fold`.
  Stream<Either<Failure, List<Habit>>> watchHabits();

  Future<Either<Failure, Habit>> getHabit(String id);

  /// The repository generates `id` and `createdAt`, validates the input
  /// and returns the stored habit.
  Future<Either<Failure, Habit>> createHabit({
    required String name,
    required String iconKey,
    required HabitColor color,
    required int dailyTarget,
    required HabitSchedule schedule,
  });

  Future<Either<Failure, Unit>> updateHabit(Habit habit);

  Future<Either<Failure, Unit>> deleteHabit(String id);
}
