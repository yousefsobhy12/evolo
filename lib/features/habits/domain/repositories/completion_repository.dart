import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class CompletionRepository {
  /// Every completion of one habit, oldest day first (feeds the streak).
  Stream<Either<Failure, List<Completion>>> watchForHabit(String habitId);

  /// Completions of all habits on one day.
  Stream<Either<Failure, List<Completion>>> watchOnDay(CalendarDay day);

  /// Every completion of every habit, ordered by habit then day (feeds the
  /// Today screen: the selected day's counts and each habit's streak come
  /// from this one stream).
  Stream<Either<Failure, List<Completion>>> watchAll();

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

  /// Adds [delta] (may be negative) to what was done on [day], atomically:
  /// the read and the write happen in one transaction, so two quick taps
  /// can never overwrite each other's increment.
  ///
  /// - The result never goes below 0 (a `-` tap on an empty day is a no-op,
  ///   not a failure). A result of 0 removes the row.
  /// - When the count does not change, nothing is written (the stored
  ///   `target` snapshot is left alone).
  /// - Otherwise the row is re-snapshotted with the habit's current
  ///   `dailyTarget`, exactly like [setCount].
  /// - A habit that does not exist => `NotFoundFailure`.
  Future<Either<Failure, Unit>> adjustCount({
    required String habitId,
    required CalendarDay day,
    required int delta,
  });
}
