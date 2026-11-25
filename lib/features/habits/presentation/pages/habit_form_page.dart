import 'dart:async';

import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/theme/app_radius.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/core/widgets/evolo_button.dart';
import 'package:evolo/core/widgets/max_content_width.dart';
import 'package:evolo/core/widgets/state_message.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_state.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_color_picker.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_icon_picker.dart';
import 'package:evolo/features/habits/presentation/widgets/target_stepper.dart';
import 'package:evolo/features/habits/presentation/widgets/weekday_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Add / edit habit. Which one it is depends on the `HabitFormCubit` given
/// above it (an id means edit). The page only draws the state and reports
/// taps; every rule lives in the cubit and the domain.
class HabitFormPage extends StatefulWidget {
  const new({super.key});

  @override
  State<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends State<HabitFormPage> {
  late final TextEditingController _nameController;

  /// The stored name (edit mode). The delete dialog names this one, because
  /// the field may already hold unsaved edits.
  String _storedName = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<HabitFormCubit>().state;
    _nameController = TextEditingController(text: state.name);
    _rememberStoredName(state);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _rememberStoredName(HabitFormState state) {
    if (_loaded || !state.isEditing) return;
    if (state.status != HabitFormStatus.ready) return;
    _storedName = state.name;
    _loaded = true;
  }

  void _onState(BuildContext context, HabitFormState state) {
    final l10n = context.l10n;

    switch (state.status) {
      case HabitFormStatus.saved:
        _leave(context, state.isEditing ? l10n.habitSaved : l10n.habitAdded);
      case HabitFormStatus.deleted:
        _leave(context, l10n.habitDeleted);
      case HabitFormStatus.unchanged:
        _leave(context);
      case HabitFormStatus.ready:
        // The habit has just been read: fill the field. (A failed save also
        // lands here, but then the field already holds the same text.)
        if (_nameController.text != state.name) {
          _nameController.text = state.name;
        }
        _rememberStoredName(state);
      case HabitFormStatus.loading ||
          HabitFormStatus.saving ||
          HabitFormStatus.deleting ||
          HabitFormStatus.loadFailed:
        break;
    }

    if (state.actionFailure != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.actionErrorMessage)));
      // Shown once, then cleared (same pattern as the Today screen).
      context.read<HabitFormCubit>().dismissActionFailure();
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HabitFormState state,
  ) async {
    final l10n = context.l10n;
    final name = (_storedName.isEmpty ? state.name : _storedName).trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteHabitTitle(name)),
        content: Text(l10n.deleteHabitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.colors.error,
            ),
            child: Text(l10n.deleteHabitConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      unawaited(context.read<HabitFormCubit>().delete());
    }
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final l10n = context.l10n;

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.colors.error,
            ),
            child: Text(l10n.discardChangesConfirm),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  /// Back is free unless there is something to lose. While a save or delete
  /// runs it is blocked.
  bool _canPop(HabitFormState state) => switch (state.status) {
    HabitFormStatus.ready => !state.isDirty,
    HabitFormStatus.saving || HabitFormStatus.deleting => false,
    HabitFormStatus.loading ||
    HabitFormStatus.saved ||
    HabitFormStatus.deleted ||
    HabitFormStatus.unchanged ||
    HabitFormStatus.loadFailed => true,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<HabitFormCubit, HabitFormState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.actionFailure != current.actionFailure,
      listener: _onState,
      child: BlocBuilder<HabitFormCubit, HabitFormState>(
        builder: (context, state) {
          return PopScope(
            canPop: _canPop(state),
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop || state.isBusy) return;
              final discard = await _confirmDiscard(context);
              if (discard && context.mounted) _leave(context);
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  state.isEditing ? l10n.editHabitTitle : l10n.newHabitTitle,
                ),
              ),
              body: MaxContentWidth(
                child: _Body(
                  state: state,
                  nameController: _nameController,
                  onDelete: () => _confirmDelete(context, state),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Closes the page, with an optional SnackBar. The messenger belongs to the
/// app, so the message survives the page and shows on Today.
void _leave(BuildContext context, [String? message]) {
  if (message != null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.today);
  }
}

class _Body extends StatelessWidget {
  const new({
    required this.state,
    required this.nameController,
    required this.onDelete,
  });

  final HabitFormState state;
  final TextEditingController nameController;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<HabitFormCubit>();

    switch (state.status) {
      case HabitFormStatus.loading:
        return Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.loading),
        );
      case HabitFormStatus.loadFailed:
        if (state.failure is NotFoundFailure) {
          return StateMessage(
            icon: Icons.search_off,
            title: l10n.habitNotFoundTitle,
            message: l10n.habitNotFoundMessage,
            action: FilledButton(
              onPressed: () => _leave(context),
              child: Text(l10n.goBack),
            ),
          );
        }
        return StateMessage(
          icon: Icons.error_outline,
          iconColor: context.colorScheme.error,
          title: l10n.loadErrorTitle,
          message: l10n.loadErrorMessage,
          action: FilledButton(onPressed: cubit.retry, child: Text(l10n.retry)),
        );
      case HabitFormStatus.ready ||
          HabitFormStatus.saving ||
          HabitFormStatus.deleting ||
          HabitFormStatus.saved ||
          HabitFormStatus.deleted ||
          HabitFormStatus.unchanged:
        return _Form(
          state: state,
          nameController: nameController,
          onDelete: onDelete,
        );
    }
  }
}

class _Form extends StatelessWidget {
  const new({
    required this.state,
    required this.nameController,
    required this.onDelete,
  });

  final HabitFormState state;
  final TextEditingController nameController;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final cubit = context.read<HabitFormCubit>();
    final editable = state.isEditable;

    return Column(
      children: [
        ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.screen,
            AppSpacing.s8,
            AppSpacing.screen,
            AppSpacing.s24,
          ),
          children: [
            _NameField(
              state: state,
              controller: nameController,
              onChanged: cubit.nameChanged,
            ),
            AppSpacing.s24.vSpace,
            _Section(
              title: l10n.habitIconLabel,
              child: HabitIconPicker(
                selectedKey: state.iconKey,
                color: state.color,
                onSelected: cubit.iconSelected,
                enabled: editable,
              ),
            ),
            _Section(
              title: l10n.habitColorLabel,
              child: HabitColorPicker(
                selected: state.color,
                onSelected: cubit.colorSelected,
                enabled: editable,
              ),
            ),
            _Section(
              title: l10n.habitTargetLabel,
              child: TargetStepper(
                value: state.dailyTarget,
                canDecrement: state.canDecrementTarget,
                canIncrement: state.canIncrementTarget,
                onDecrement: cubit.decrementTarget,
                onIncrement: cubit.incrementTarget,
                enabled: editable,
              ),
            ),
            _Section(
              title: l10n.habitDaysLabel,
              child: _DaysSection(state: state),
            ),
            if (state.isEditing) ...[
              AppSpacing.s8.vSpace,
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: editable ? onDelete : null,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.error,
                    minimumSize: const Size(0, 48),
                  ),
                  icon: state.status == HabitFormStatus.deleting
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colors.error,
                            semanticsLabel: l10n.loading,
                          ),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text(l10n.deleteHabit),
                ),
              ),
            ],
          ],
        ).expanded(),
        // Outside the scroll, so Save stays reachable above the keyboard.
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.screen,
              AppSpacing.s8,
              AppSpacing.screen,
              AppSpacing.s16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: EvoloButton(
                label: l10n.saveHabit,
                loadingLabel: l10n.savingHabit,
                isLoading: state.status == HabitFormStatus.saving,
                onPressed: editable
                    ? () {
                        FocusScope.of(context).unfocus();
                        unawaited(cubit.submit());
                      }
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  const new({
    required this.state,
    required this.controller,
    required this.onChanged,
  });

  final HabitFormState state;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final tooLong = state.nameError == ValidationReason.nameTooLong;

    final errorText = switch (state.nameError) {
      ValidationReason.nameEmpty => l10n.habitNameEmptyError,
      ValidationReason.nameTooLong => context.formatters.digits(
        l10n.habitNameTooLongError(Habit.maxNameLength),
      ),
      _ => null,
    };

    return TextField(
      controller: controller,
      enabled: state.isEditable,
      autofocus: !state.isEditing,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      // By the language of what is typed (null while it has no letters yet:
      // then the app's own direction applies).
      textDirection: state.name.detectedTextDirection,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: l10n.habitNameLabel,
        hintText: l10n.habitNameHint,
        errorText: errorText,
        counter: Text(
          context.formatters.digits(
            l10n.habitNameCounter(state.nameLength, Habit.maxNameLength),
          ),
          style: context.textTheme.bodySmall?.copyWith(
            color: tooLong ? colors.error : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const new({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: context.textTheme.titleMedium),
          ),
          AppSpacing.s12.vSpace,
          child,
        ],
      ),
    );
  }
}

class _DaysSection extends StatelessWidget {
  const new({required this.state});

  final HabitFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final cubit = context.read<HabitFormCubit>();
    final caption = context.textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WeekdayPicker(
          selected: state.days,
          onToggle: cubit.dayToggled,
          enabled: state.isEditable,
        ),
        AppSpacing.s8.vSpace,
        if (state.daysError != null)
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.habitDaysError,
              style: caption?.copyWith(color: colors.error),
            ),
          )
        else
          Text(
            _summary(context, state.days),
            style: caption?.copyWith(color: colors.textSecondary),
          ),
        if (state.scheduleChanged) ...[
          AppSpacing.s12.vSpace,
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.tile),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.s12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                  AppSpacing.s8.hSpace,
                  Text(l10n.scheduleChangeWarning, style: caption).expanded(),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// "Every day", or the chosen days in picker order ("Sat, Mon, Wed").
  String _summary(BuildContext context, Set<Weekday> days) {
    if (days.length == Weekday.values.length) {
      return context.l10n.daysEveryDay;
    }
    final formatters = context.formatters;
    final separator = Localizations.localeOf(context).languageCode == 'ar'
        ? '، '
        : ', ';
    return [
      for (final day in WeekdayPicker.displayOrder)
        if (days.contains(day))
          formatters.weekdayShort(DateTime(2024, 1, 1 + day.index)),
    ].join(separator);
  }
}
