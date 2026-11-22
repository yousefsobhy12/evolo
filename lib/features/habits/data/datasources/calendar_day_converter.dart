import 'package:drift/drift.dart';
import 'package:evolo/core/utils/calendar_day.dart';

/// Stores a [CalendarDay] as `yyyy-MM-dd` text. Text order equals
/// chronological order, and the value never depends on a time zone.
class CalendarDayConverter extends TypeConverter<CalendarDay, String> {
  const new();

  /// Throws [FormatException] on a corrupt value. The repository catches it.
  @override
  CalendarDay fromSql(String fromDb) => CalendarDay.parse(fromDb);

  @override
  String toSql(CalendarDay value) => value.toIsoString();
}
