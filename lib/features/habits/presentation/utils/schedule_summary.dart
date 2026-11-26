import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/presentation/widgets/weekday_picker.dart';
import 'package:flutter/widgets.dart';

/// "Every day", or the chosen days in picker order ("Sat, Mon, Wed").
String scheduleSummary(BuildContext context, Set<Weekday> days) {
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
        // Any date works, only its weekday matters: 2024-01-01 is a Monday.
        formatters.weekdayShort(DateTime(2024, 1, 1 + day.index)),
  ].join(separator);
}
