import 'package:equatable/equatable.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';

/// Where the add / edit form is in its life.
enum HabitFormStatus {
  /// Edit mode: the habit is being read.
  loading,

  /// The form can be edited.
  ready,

  /// A save is running. Inputs are locked.
  saving,

  /// A delete is running. Inputs are locked.
  deleting,

  /// Saved. One-shot: the page confirms and closes.
  saved,

  /// Deleted, or already gone. One-shot: the page confirms and closes.
  deleted,

  /// Edit mode, Save pressed with nothing changed. The page just closes.
  unchanged,

  /// The form cannot be shown: the habit could not be read, or it no longer
  /// exists. See [HabitFormState.failure].
  loadFailed,
}

/// Everything the add / edit form draws. One class (not one per status) so
/// what the user typed survives a failed save.
final class HabitFormState extends Equatable {
  const new({
    required this.habitId,
    required this.status,
    required this.name,
    required this.iconKey,
    required this.color,
    required this.dailyTarget,
    required this.days,
    this.nameError,
    this.daysError,
    this.isDirty = false,
    this.scheduleChanged = false,
    this.failure,
    this.actionFailure,
  });

  /// Null when adding a new habit.
  final String? habitId;

  final HabitFormStatus status;

  /// The name exactly as typed (not trimmed).
  final String name;
  final String iconKey;
  final HabitColor color;
  final int dailyTarget;
  final Set<Weekday> days;

  /// Why the name is not acceptable. Set only once the user has edited the
  /// field or tried to save, so an untouched form does not open with an error.
  final ValidationReason? nameError;

  /// Why the days are not acceptable (none selected). Always up to date: the
  /// only way to get there is to deselect, which is an interaction already.
  final ValidationReason? daysError;

  /// Whether anything differs from the starting point: the defaults when
  /// adding, the stored habit when editing. Drives the "discard changes?"
  /// prompt.
  final bool isDirty;

  /// Edit mode only: the days differ from the stored habit. Changing the
  /// days applies to the whole history, so the page shows a short warning.
  final bool scheduleChanged;

  /// Why the form cannot be shown. Set only when [status] is loadFailed.
  final Failure? failure;

  /// A failed save or delete. The page shows it once (a SnackBar) and then
  /// calls `dismissActionFailure`.
  final Failure? actionFailure;

  bool get isEditing => habitId != null;

  /// Measured the way the domain rule measures it, so the counter and the
  /// rule always agree (an emoji counts as 2).
  int get nameLength => Habit.nameLength(name);

  bool get canDecrementTarget => dailyTarget > Habit.minDailyTarget;
  bool get canIncrementTarget => dailyTarget < Habit.maxDailyTarget;

  /// Inputs can be changed.
  bool get isEditable => status == HabitFormStatus.ready;

  /// A save or delete is in flight.
  bool get isBusy =>
      status == HabitFormStatus.saving || status == HabitFormStatus.deleting;

  @override
  List<Object?> get props => [
    habitId,
    status,
    name,
    iconKey,
    color,
    dailyTarget,
    // Sorted list so equality never depends on Set ordering/implementation.
    (days.map((d) => d.index).toList()..sort()),
    nameError,
    daysError,
    isDirty,
    scheduleChanged,
    failure,
    actionFailure,
  ];
}
