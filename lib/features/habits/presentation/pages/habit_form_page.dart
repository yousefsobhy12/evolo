import 'dart:async';

import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/theme/app_radius.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/core/widgets/circle_icon_button.dart';
import 'package:evolo/core/widgets/evolo_button.dart';
import 'package:evolo/core/widgets/max_content_width.dart';
import 'package:evolo/core/widgets/page_header.dart';
import 'package:evolo/core/widgets/page_status_bar.dart';
import 'package:evolo/core/widgets/state_message.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_state.dart';
import 'package:evolo/features/habits/presentation/utils/schedule_summary.dart';
import 'package:evolo/features/habits/presentation/widgets/calendar_illustration.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_appearance_field.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_appearance_sheet.dart';
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

  /// Leaves the page, asking first when there is something to lose. Used by
  /// the system back (when it is blocked) and by the close button.
  Future<void> _requestClose(BuildContext context) async {
    final state = context.read<HabitFormCubit>().state;
    if (state.isBusy) return;
    if (!_canPop(state)) {
      final discard = await _confirmDiscard(context);
      if (!discard || !context.mounted) return;
    }
    _leave(context);
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
              if (!didPop) await _requestClose(context);
            },
            child: PageStatusBar(
              child: Scaffold(
                body: SafeArea(
                  bottom: false,
                  child: MaxContentWidth(
                    child: _Body(
                      state: state,
                      header: PageHeader(
                        title: state.isEditing
                            ? l10n.editHabitTitle
                            : l10n.newHabitTitle,
                        trailing: CircleIconButton(
                          icon: Icons.close,
                          tooltip: MaterialLocalizations.of(context)
                              .closeButtonTooltip,
                          onPressed: state.isBusy
                              ? null
                              : () => unawaited(_requestClose(context)),
                        ),
                      ),
                      nameController: _nameController,
                      onDelete: () => _confirmDelete(context, state),
                    ),
                  ),
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
    required this.header,
    required this.nameController,
    required this.onDelete,
  });

  final HabitFormState state;
  final Widget header;
  final TextEditingController nameController;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case HabitFormStatus.loading || HabitFormStatus.loadFailed:
        // The header stays, so the page can always be closed.
        return Column(children: [header, _status(context).expanded()]);
      case HabitFormStatus.ready ||
          HabitFormStatus.saving ||
          HabitFormStatus.deleting ||
          HabitFormStatus.saved ||
          HabitFormStatus.deleted ||
          HabitFormStatus.unchanged:
        return _Form(
          state: state,
          header: header,
          nameController: nameController,
          onDelete: onDelete,
        );
    }
  }

  Widget _status(BuildContext context) {
    final l10n = context.l10n;

    if (state.status == HabitFormStatus.loading) {
      return Center(
        child: CircularProgressIndicator(semanticsLabel: l10n.loading),
      );
    }
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
      action: FilledButton(
        onPressed: context.read<HabitFormCubit>().retry,
        child: Text(l10n.retry),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const new({
    required this.state,
    required this.header,
    required this.nameController,
    required this.onDelete,
  });

  final HabitFormState state;
  final Widget header;
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
          padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.s24),
          children: [
            // Brings its own side padding, so it sits outside the Padding.
            header,
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: CalendarIllustration()),
                  AppSpacing.s24.vSpace,
                  _Section(
                    title: l10n.habitNameLabel,
                    child: _NameField(
                      state: state,
                      controller: nameController,
                      onChanged: cubit.nameChanged,
                    ),
                  ),
                  _Section(
                    title: l10n.habitAppearanceLabel,
                    child: HabitAppearanceField(
                      iconKey: state.iconKey,
                      color: state.color,
                      onPressed: editable
                          ? () {
                              // Closes the keyboard, and stops it from
                              // coming back when the sheet closes.
                              FocusManager.instance.primaryFocus?.unfocus();
                              unawaited(showHabitAppearanceSheet(context));
                            }
                          : null,
                    ),
                  ),
                  _Section(
                    title: l10n.habitTargetLabel,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.s8),
                        child: TargetStepper(
                          value: state.dailyTarget,
                          canDecrement: state.canDecrementTarget,
                          canIncrement: state.canIncrementTarget,
                          onDecrement: cubit.decrementTarget,
                          onIncrement: cubit.incrementTarget,
                          enabled: editable,
                        ),
                      ),
                    ),
                  ),
                  _Section(
                    title: l10n.habitDaysLabel,
                    trailing: _SelectAll(
                      isSelected: state.allDaysSelected,
                      onPressed: editable ? cubit.allDaysToggled : null,
                    ),
                    child: _DaysSection(state: state),
                  ),
                  if (state.isEditing)
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
              ),
            ),
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

    // The visible label sits above the field, so the field gets its name for
    // screen readers here.
    return Semantics(
      label: l10n.habitNameLabel,
      child: TextField(
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
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const new({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;

  /// At the end of the title line.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A Wrap, not a Row: with a big font the trailing widget drops to
          // its own line instead of overflowing.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.s8,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: context.textTheme.titleMedium),
                ),
                ?trailing,
              ],
            ),
          ),
          AppSpacing.s12.vSpace,
          child,
        ],
      ),
    );
  }
}

/// A checkbox-like text button: checked when every day is selected.
class _SelectAll extends StatelessWidget {
  const new({required this.isSelected, required this.onPressed});

  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Merged, so a screen reader hears one control: name + checked state.
    return MergeSemantics(
      child: Semantics(
        checked: isSelected,
        child: TextButton.icon(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: context.colors.textAccent,
            minimumSize: const Size(48, 48),
          ),
          icon: Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
          ),
          label: Text(context.l10n.selectAllDays),
        ),
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
            scheduleSummary(context, state.days),
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
}
