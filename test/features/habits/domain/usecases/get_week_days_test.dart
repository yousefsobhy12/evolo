import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/usecases/get_week_days.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const getWeekDays = GetWeekDays();

  List<CalendarDay> week(CalendarDay day, Weekday firstDay) =>
      getWeekDays(day: day, firstDay: firstDay);

  // 2026-11-22 is a Sunday.
  final sunday = CalendarDay(2026, 11, 22);

  group('a week starting on Saturday (Egypt)', () {
    test('Sunday belongs to the week that started the day before', () {
      final result = week(sunday, Weekday.saturday);

      expect(result, hasLength(7));
      expect(result.first, CalendarDay(2026, 11, 21));
      expect(result.last, CalendarDay(2026, 11, 27));
    });

    test('Saturday is the first day of its own week', () {
      final result = week(CalendarDay(2026, 11, 21), Weekday.saturday);

      expect(result.first, CalendarDay(2026, 11, 21));
    });

    test('Friday is the last day of the week', () {
      final result = week(CalendarDay(2026, 11, 27), Weekday.saturday);

      expect(result.first, CalendarDay(2026, 11, 21));
      expect(result.last, CalendarDay(2026, 11, 27));
    });

    test('a week can cross the end of the year', () {
      final result = week(CalendarDay(2026, 12, 31), Weekday.saturday);

      expect(result.first, CalendarDay(2026, 12, 26));
      expect(result.last, CalendarDay(2027, 1, 1));
    });
  });

  group('other first days', () {
    test('Monday', () {
      final result = week(sunday, Weekday.monday);

      expect(result.first, CalendarDay(2026, 11, 16));
      expect(result.last, CalendarDay(2026, 11, 22));
    });

    test('Sunday', () {
      final result = week(sunday, Weekday.sunday);

      expect(result.first, CalendarDay(2026, 11, 22));
      expect(result.last, CalendarDay(2026, 11, 28));
    });
  });

  test(
    'for every day of 2026 and every first day, the week is well formed',
    () {
      final lastDay = CalendarDay(2026, 12, 31);
      for (final firstDay in Weekday.values) {
        for (
          var day = CalendarDay(2026, 1, 1);
          !day.isAfter(lastDay);
          day = day.addDays(1)
        ) {
          final result = week(day, firstDay);

          expect(result, hasLength(7), reason: '$day / $firstDay');
          expect(result, contains(day), reason: '$day / $firstDay');
          expect(
            Weekday.fromDateTime(result.first.toDateTime()),
            firstDay,
            reason: '$day / $firstDay',
          );
          for (var i = 1; i < result.length; i++) {
            expect(result[i], result[i - 1].addDays(1), reason: '$day');
          }
        }
      }
    },
  );
}
