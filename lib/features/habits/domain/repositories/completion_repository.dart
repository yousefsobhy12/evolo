import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class CompletionRepository {
  /// Every completion of one habit, oldest day first (feeds the streak).
  Stream<Either<Failure, List<Completion>>> watchForHabit(String habitId);

  /// Completions of all habits on one day (feeds the Today screen).
  Stream<Either<Failure, List<Completion>>> watchOnDay(CalendarDay day);

  /// Sets how much of [habitId] was done on [day].
  ///
  /// - `count == 0` removes the row.
  /// - The repository reads the habit's current `dailyTarget` itself and
  ///   stores it as the snapshot, so callers cannot pass a wrong one.
  /// - A habit that does not exist => `NotFoundFailure`.
  /// - A negative count => `ValidationFailure`.
  Future<Either<Failure, Unit>> setCount({
    required String habitId,
    required CalendarDay day,
    required int count,
  });
}
