import 'dart:async';

import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_state.dart';
import 'package:evolo/features/habits/presentation/utils/habit_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

class HabitFormCubit extends Cubit<HabitFormState> {
  new(this._repository, {required String defaultIconKey, String? habitId})
    : _habitId = habitId,
      _defaultIconKey = defaultIconKey,
      _iconKey = defaultIconKey,
      _status = habitId == null
          ? HabitFormStatus.ready
          : HabitFormStatus.loading,
      super(
        HabitFormState(
          habitId: habitId,
          status: habitId == null
              ? HabitFormStatus.ready
              : HabitFormStatus.loading,
          name: '',
          iconKey: defaultIconKey,
          color: _defaultColor,
          dailyTarget: Habit.minDailyTarget,
          days: HabitSchedule.everyDay().days,
        ),
      ) {
    if (habitId != null) unawaited(_load());
  }

  static const HabitColor _defaultColor = HabitColor.orange;

  final HabitRepository _repository;
  final String? _habitId;
  final String _defaultIconKey;

  /// The stored habit, once it has been read (edit mode only).
  Habit? _original;

  String _name = '';
  String _iconKey;
  HabitColor _color = _defaultColor;
  int _dailyTarget = Habit.minDailyTarget;
  Set<Weekday> _days = HabitSchedule.everyDay().days;

  // Errors stay hidden until the user has had a chance to type.
  bool _nameTouched = false;
  bool _submitAttempted = false;

  HabitFormStatus _status;
  Failure? _failure;
  Failure? _actionFailure;

  // --- Loading (edit mode) -------------------------------------------------

  Future<void> _load() async {
    _status = HabitFormStatus.loading;
    _failure = null;
    _publish();

    final result = await _repository.getHabit(_habitId!);
    result.fold<void>(
      (failure) {
        _failure = failure;
        _status = HabitFormStatus.loadFailed;
      },
      (habit) {
        _original = habit;
        _name = habit.name;
        _iconKey = habit.iconKey;
        _color = habit.color;
        _dailyTarget = habit.dailyTarget;
        _days = Set.of(habit.schedule.days);
        _status = HabitFormStatus.ready;
      },
    );
    _publish();
  }

  /// Reads the habit again after a failed load.
  Future<void> retry() async {
    if (_habitId == null || _status != HabitFormStatus.loadFailed) return;
    await _load();
  }

  // --- Editing the fields --------------------------------------------------
  // All of them are ignored unless the form is ready: while a save or a delete
  // is running the inputs are locked.

  void nameChanged(String value) {
    if (!_isEditable) return;
    _name = value;
    _nameTouched = true;
    _publish();
  }

  /// Ignores keys that are not in the icon registry.
  void iconSelected(String key) {
    if (!_isEditable || !HabitIcons.isKnown(key)) return;
    _iconKey = key;
    _publish();
  }

  void colorSelected(HabitColor color) {
    if (!_isEditable) return;
    _color = color;
    _publish();
  }

  /// Stops at [Habit.maxDailyTarget].
  void incrementTarget() {
    if (!_isEditable || _dailyTarget >= Habit.maxDailyTarget) return;
    _dailyTarget++;
    _publish();
  }

  /// Stops at [Habit.minDailyTarget].
  void decrementTarget() {
    if (!_isEditable || _dailyTarget <= Habit.minDailyTarget) return;
    _dailyTarget--;
    _publish();
  }

  /// Selects or deselects [day]. Deselecting the last one is allowed: the
  /// state then carries a `daysError` and saving is refused.
  void dayToggled(Weekday day) {
    if (!_isEditable) return;
    _days = _days.contains(day) ? ({..._days}..remove(day)) : {..._days, day};
    _publish();
  }

  // --- Save ----------------------------------------------------------------

  /// Validates and then creates (add) or updates (edit) the habit.
  ///
  /// With errors it only reveals them. In edit mode with nothing changed it
  /// closes without writing anything. A second press while a save is running
  /// is ignored.
  Future<void> submit() async {
    if (!_isEditable) return;

    _submitAttempted = true;
    if (Habit.validateName(_name) != null ||
        Habit.validateDays(_days) != null) {
      _publish();
      return;
    }

    final original = _original;
    if (original != null && !_isDirty) {
      _status = HabitFormStatus.unchanged;
      _publish();
      return;
    }

    _status = HabitFormStatus.saving;
    _actionFailure = null;
    _publish();

    final name = _name.trim();
    final schedule = HabitSchedule(_days);
    final Either<Failure, Unit> result;
    if (original == null) {
      final created = await _repository.createHabit(
        name: name,
        iconKey: _iconKey,
        color: _color,
        dailyTarget: _dailyTarget,
        schedule: schedule,
      );
      result = created.map((_) => unit);
    } else {
      result = await _repository.updateHabit(
        original.copyWith(
          name: name,
          iconKey: _iconKey,
          color: _color,
          dailyTarget: _dailyTarget,
          schedule: schedule,
        ),
      );
    }

    result.fold<void>((failure) {
      if (original != null && failure is NotFoundFailure) {
        // Deleted while the form was open: there is nothing left to edit.
        _failure = failure;
        _status = HabitFormStatus.loadFailed;
      } else {
        _actionFailure = failure;
        _status = HabitFormStatus.ready;
      }
    }, (_) => _status = HabitFormStatus.saved);
    _publish();
  }

  // --- Delete (edit mode) --------------------------------------------------

  /// Deletes the habit being edited. Does nothing when adding. Deleting a
  /// habit that is already gone counts as done: the goal is reached.
  Future<void> delete() async {
    final id = _habitId;
    if (id == null || !_isEditable) return;

    _status = HabitFormStatus.deleting;
    _actionFailure = null;
    _publish();

    final result = await _repository.deleteHabit(id);
    result.fold<void>((failure) {
      if (failure is NotFoundFailure) {
        _status = HabitFormStatus.deleted;
      } else {
        _actionFailure = failure;
        _status = HabitFormStatus.ready;
      }
    }, (_) => _status = HabitFormStatus.deleted);
    _publish();
  }

  /// Call after the page has shown [HabitFormState.actionFailure].
  void dismissActionFailure() {
    if (_actionFailure == null) return;
    _actionFailure = null;
    _publish();
  }

  // --- State ---------------------------------------------------------------

  bool get _isEditable => _status == HabitFormStatus.ready;

  /// Whether anything differs from the starting point: the stored habit when
  /// editing, the defaults when adding.
  bool get _isDirty {
    final original = _original;
    if (original == null) {
      // Edit mode before the habit has been read: nothing to compare with.
      if (_habitId != null) return false;
      return _name.trim().isNotEmpty ||
          _iconKey != _defaultIconKey ||
          _color != _defaultColor ||
          _dailyTarget != Habit.minDailyTarget ||
          !_sameDays(_days, HabitSchedule.everyDay().days);
    }
    return _name.trim() != original.name ||
        _iconKey != original.iconKey ||
        _color != original.color ||
        _dailyTarget != original.dailyTarget ||
        !_sameDays(_days, original.schedule.days);
  }

  static bool _sameDays(Set<Weekday> a, Set<Weekday> b) =>
      a.length == b.length && a.containsAll(b);

  void _publish() {
    if (isClosed) return;
    final original = _original;
    final next = HabitFormState(
      habitId: _habitId,
      status: _status,
      name: _name,
      iconKey: _iconKey,
      color: _color,
      dailyTarget: _dailyTarget,
      days: Set.unmodifiable(_days),
      nameError: _nameTouched || _submitAttempted
          ? Habit.validateName(_name)
          : null,
      daysError: Habit.validateDays(_days),
      isDirty: _isDirty,
      scheduleChanged:
          original != null && !_sameDays(_days, original.schedule.days),
      failure: _failure,
      actionFailure: _actionFailure,
    );
    // The Cubit emits its very first state even when it equals the initial
    // one, so equal states are filtered here.
    if (next == state) return;
    emit(next);
  }
}
