import 'dart:async';

import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/features/habits/data/datasources/habits_dao.dart';
import 'package:evolo/features/habits/data/mappers/habit_mapper.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class HabitRepositoryImpl implements HabitRepository {
  new(this._dao, {String Function()? generateId, DateTime Function()? now})
    : _generateId = generateId ?? const Uuid().v4,
      _now = now ?? DateTime.now;

  final HabitsDao _dao;
  final String Function() _generateId;
  final DateTime Function() _now;

  @override
  Stream<Either<Failure, List<Habit>>> watchHabits() {
    return _dao.watchAll().transform(
      StreamTransformer<
        List<HabitRow>,
        Either<Failure, List<Habit>>
      >.fromHandlers(
        handleData: (rows, sink) =>
            sink.add(Right(rows.map((row) => row.toEntity()).toList())),
        handleError: (error, _, sink) =>
            sink.add(Left(DatabaseFailure(cause: error))),
      ),
    );
  }

  @override
  Future<Either<Failure, Habit>> getHabit(String id) {
    return _guard<Habit>(() async {
      final row = await _dao.findById(id);
      if (row == null) return const Left(NotFoundFailure());
      return Right(row.toEntity());
    });
  }

  @override
  Future<Either<Failure, Habit>> createHabit({
    required String name,
    required String iconKey,
    required HabitColor color,
    required int dailyTarget,
    required HabitSchedule schedule,
  }) {
    return _guard<Habit>(() async {
      final reason = Habit.validate(
        name: name,
        dailyTarget: dailyTarget,
        schedule: schedule,
      );
      if (reason != null) return Left(ValidationFailure(reason));

      final row = await _dao.insertHabit(
        HabitsCompanion.insert(
          id: _generateId(),
          name: name.trim(),
          iconKey: iconKey,
          color: color,
          dailyTarget: dailyTarget,
          schedule: schedule,
          createdAt: _now(),
        ),
      );
      return Right(row.toEntity());
    });
  }

  @override
  Future<Either<Failure, Unit>> updateHabit(Habit habit) {
    return _guard<Unit>(() async {
      final reason = Habit.validate(
        name: habit.name,
        dailyTarget: habit.dailyTarget,
        schedule: habit.schedule,
      );
      if (reason != null) return Left(ValidationFailure(reason));

      final cleaned = habit.copyWith(name: habit.name.trim());
      final changed = await _dao.updateById(
        cleaned.id,
        cleaned.toUpdateCompanion(),
      );
      if (changed == 0) return const Left(NotFoundFailure());
      return const Right(unit);
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteHabit(String id) {
    return _guard<Unit>(() async {
      final deleted = await _dao.deleteById(id);
      if (deleted == 0) return const Left(NotFoundFailure());
      return const Right(unit);
    });
  }

  /// The only place that catches. Nothing thrown inside [action] can
  /// leave the repository: it comes out as a `Left`.
  Future<Either<Failure, T>> _guard<T>(
    Future<Either<Failure, T>> Function() action,
  ) async {
    try {
      return await action();
    } on Exception catch (error) {
      return Left(DatabaseFailure(cause: error));
    } on Object catch (error) {
      return Left(UnexpectedFailure(cause: error));
    }
  }
}
