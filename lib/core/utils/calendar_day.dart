import 'package:equatable/equatable.dart';

/// A calendar date (year/month/day) with no time and no time zone.
///
/// "Which day is it" is decided once, from the device's local date, and from
/// then on it is just three integers. That is why it is stored as text
/// (`yyyy-MM-dd`) and never as an epoch timestamp.
final class CalendarDay extends Equatable implements Comparable<CalendarDay> {
  /// Throws [ArgumentError] for dates that do not exist (e.g. Feb 30).
  factory(int year, int month, int day) {
    if (!_isValid(year, month, day)) {
      throw ArgumentError('Invalid calendar day: $year-$month-$day');
    }
    return CalendarDay._(year, month, day);
  }

  /// Takes the *local* date of [dateTime] (a UTC value is converted first).
  factory fromDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return CalendarDay._(local.year, local.month, local.day);
  }

  /// Parses `yyyy-MM-dd`. Throws [FormatException] otherwise.
  factory parse(String source) {
    final match = _isoPattern.firstMatch(source);
    if (match == null) {
      throw FormatException('Expected yyyy-MM-dd', source);
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    if (!_isValid(year, month, day)) {
      throw FormatException('Not a real calendar date', source);
    }
    return CalendarDay._(year, month, day);
  }

  const new _(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  static final _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  static bool _isValid(int year, int month, int day) {
    // DateTime normalises overflow (month 13, day 31 in April...). If the
    // fields survive a round trip, the date is real.
    final normalized = DateTime.utc(year, month, day);
    return normalized.year == year &&
        normalized.month == month &&
        normalized.day == day;
  }

  /// Day arithmetic is done in UTC, where every day is exactly 24h, so a
  /// daylight-saving change can never skip or repeat a day.
  CalendarDay addDays(int days) {
    final shifted = DateTime.utc(year, month, day + days);
    return CalendarDay._(shifted.year, shifted.month, shifted.day);
  }

  bool isBefore(CalendarDay other) => compareTo(other) < 0;

  bool isAfter(CalendarDay other) => compareTo(other) > 0;

  /// A local [DateTime] on this day, at 12:00 on purpose: midnight may not
  /// exist on the day clocks jump forward (some zones switch at 00:00).
  DateTime toDateTime() => DateTime(year, month, day, 12);

  /// `yyyy-MM-dd`. Text order equals chronological order.
  String toIsoString() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  int compareTo(CalendarDay other) {
    final byYear = year.compareTo(other.year);
    if (byYear != 0) return byYear;
    final byMonth = month.compareTo(other.month);
    if (byMonth != 0) return byMonth;
    return day.compareTo(other.day);
  }

  @override
  List<Object> get props => [year, month, day];

  @override
  String toString() => toIsoString();
}
