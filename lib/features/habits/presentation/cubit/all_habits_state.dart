import 'package:equatable/equatable.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';

enum AllHabitsStatus { loading, success, failure }

/// Everything the "All habits" screen draws. An empty [habits] with a success
/// status is the empty state.
final class AllHabitsState extends Equatable {
  const new({
    this.status = AllHabitsStatus.loading,
    this.habits = const [],
    this.failure,
  });

  final AllHabitsStatus status;

  /// In the repository's order (oldest first). Empty unless success.
  final List<Habit> habits;

  /// Why loading failed. Set only when [status] is failure.
  final Failure? failure;

  @override
  List<Object?> get props => [status, habits, failure];
}
