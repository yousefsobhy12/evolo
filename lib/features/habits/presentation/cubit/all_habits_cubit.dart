import 'dart:async';

import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/presentation/cubit/all_habits_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

/// Drives the "All habits" screen.
///
/// Plain reading, so there is no usecase: it listens to the repository's
/// stream. Adding, editing or deleting in the form shows here by itself.
class AllHabitsCubit extends Cubit<AllHabitsState> {
  new(this._repository) : super(const AllHabitsState()) {
    _subscribe();
  }

  final HabitRepository _repository;
  StreamSubscription<Either<Failure, List<Habit>>>? _subscription;

  /// Subscribes again after a load failure.
  Future<void> retry() async {
    await _subscription?.cancel();
    if (isClosed) return;
    emit(const AllHabitsState());
    _subscribe();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return await super.close();
  }

  void _subscribe() {
    _subscription = _repository.watchHabits().listen((result) {
      emit(
        result.fold(
          (failure) =>
              AllHabitsState(status: AllHabitsStatus.failure, failure: failure),
          (habits) =>
              AllHabitsState(status: AllHabitsStatus.success, habits: habits),
        ),
      );
    });
  }
}
