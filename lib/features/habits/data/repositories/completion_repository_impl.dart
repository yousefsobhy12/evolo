import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/errors/guard.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/data/datasources/completions_dao.dart';
import 'package:evolo/features/habits/data/mappers/completion_mapper.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/repositories/completion_repository.dart';
import 'package:fpdart/fpdart.dart';

class CompletionRepositoryImpl implements CompletionRepository {
  new(this._dao);

  final CompletionsDao _dao;

  @override
  Stream<Either<Failure, List<Completion>>> watchForHabit(String habitId) {
    return _dao.watchForHabit(habitId).mapToEither(_toEntities);
  }

  @override
  Stream<Either<Failure, List<Completion>>> watchOnDay(CalendarDay day) {
    return _dao.watchOnDay(day).mapToEither(_toEntities);
  }

  @override
  Stream<Either<Failure, List<Completion>>> watchAll() {
    return _dao.watchAll().mapToEither(_toEntities);
  }

  @override
  Future<Either<Failure, Unit>> adjustCount({
    required String habitId,
    required CalendarDay day,
    required int delta,
  }) {
    return guard<Unit>(() async {
      final habitExists = await _dao.adjustCount(
        habitId: habitId,
        day: day,
        delta: delta,
      );
      if (!habitExists) return const Left(NotFoundFailure());
      return const Right(unit);
    });
  }

  @override
  Future<Either<Failure, Unit>> setCount({
    required String habitId,
    required CalendarDay day,
    required int count,
  }) {
    return guard<Unit>(() async {
      if (count < 0) {
        return const Left(ValidationFailure(ValidationReason.negativeCount));
      }
      final habitExists = await _dao.setCount(
        habitId: habitId,
        day: day,
        count: count,
      );
      if (!habitExists) return const Left(NotFoundFailure());
      return const Right(unit);
    });
  }

  static List<Completion> _toEntities(List<CompletionRow> rows) => [
    for (final row in rows) row.toEntity(),
  ];
}
