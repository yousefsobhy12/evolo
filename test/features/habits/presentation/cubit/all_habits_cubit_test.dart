import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/presentation/cubit/all_habits_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/all_habits_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/habit_fixtures.dart';

class MockHabitRepository extends Mock implements HabitRepository;

void main() {
  final read = todayItem(name: 'Read').habit;
  late MockHabitRepository repository;
  late StreamController<Either<Failure, List<Habit>>> controller;

  setUp(() {
    repository = MockHabitRepository();
    controller = StreamController<Either<Failure, List<Habit>>>.broadcast();
    addTearDown(controller.close);
    when(repository.watchHabits).thenAnswer((_) => controller.stream);
  });

  test('starts loading', () {
    final cubit = AllHabitsCubit(repository);
    addTearDown(cubit.close);

    expect(cubit.state, const AllHabitsState());
  });

  blocTest<AllHabitsCubit, AllHabitsState>(
    'follows the stream: habits, then an empty list',
    build: () => AllHabitsCubit(repository),
    act: (_) => controller
      ..add(Right([read]))
      ..add(const Right([])),
    expect: () => [
      AllHabitsState(status: AllHabitsStatus.success, habits: [read]),
      const AllHabitsState(status: AllHabitsStatus.success),
    ],
  );

  blocTest<AllHabitsCubit, AllHabitsState>(
    'a read error is a failure state',
    build: () => AllHabitsCubit(repository),
    act: (_) => controller.add(const Left(DatabaseFailure())),
    expect: () => [
      const AllHabitsState(
        status: AllHabitsStatus.failure,
        failure: DatabaseFailure(),
      ),
    ],
  );

  blocTest<AllHabitsCubit, AllHabitsState>(
    'retry goes back to loading and subscribes again',
    build: () => AllHabitsCubit(repository),
    act: (cubit) async {
      controller.add(const Left(DatabaseFailure()));
      await Future<void>.delayed(Duration.zero);
      await cubit.retry();
      controller.add(Right([read]));
    },
    skip: 1,
    expect: () => [
      const AllHabitsState(),
      AllHabitsState(status: AllHabitsStatus.success, habits: [read]),
    ],
    verify: (_) => verify(repository.watchHabits).called(2),
  );

  test('close cancels the subscription', () async {
    final cubit = AllHabitsCubit(repository);
    expect(controller.hasListener, isTrue);

    await cubit.close();

    expect(controller.hasListener, isFalse);
  });
}
