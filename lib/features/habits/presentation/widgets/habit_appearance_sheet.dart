import 'package:evolo/core/extensions/extensions.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_spacing.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_state.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_color_picker.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_icon_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Opens the color and icon pickers in a bottom sheet.
///
/// A choice applies at once (the form behind is the preview), so there is no
/// draft to confirm or cancel: "Done" only closes.
Future<void> showHabitAppearanceSheet(BuildContext context) {
  // The sheet is a separate route: it does not see the page's providers, so
  // the cubit is handed over by value (the page still owns and closes it).
  final cubit = context.read<HabitFormCubit>();

  return showModalBottomSheet<void>(
    context: context,
    // Lets the sheet be taller than half the screen.
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: context.colors.background,
    builder: (_) => BlocProvider<HabitFormCubit>.value(
      value: cubit,
      child: const _AppearanceSheet(),
    ),
  );
}

class _AppearanceSheet extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<HabitFormCubit>();

    return BlocBuilder<HabitFormCubit, HabitFormState>(
      builder: (context, state) => SafeArea(
        top: false,
        child: Column(
          // As tall as the content, up to the screen.
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Heading(l10n.habitColorLabel),
                  HabitColorPicker(
                    selected: state.color,
                    onSelected: cubit.colorSelected,
                    enabled: state.isEditable,
                  ),
                  AppSpacing.s24.vSpace,
                  _Heading(l10n.habitIconLabel),
                  HabitIconPicker(
                    selectedKey: state.iconKey,
                    color: state.color,
                    onSelected: cubit.iconSelected,
                    enabled: state.isEditable,
                  ),
                ],
              ),
            ).flexible(),
            // Outside the scroll, so it is always reachable.
            Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.screen),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.done),
              ).fullWidth(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: context.textTheme.titleMedium),
    ).paddingDirectional(bottom: AppSpacing.s12);
  }
}
