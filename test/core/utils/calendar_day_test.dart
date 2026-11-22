import 'package:evolo/core/utils/calendar_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('construction', () {
    test('accepts Feb 29 only in a leap year', () {
      expect(() => CalendarDay(2028, 2, 29), returnsNormally);
      expect(() => CalendarDay(2026, 2, 29), throwsArgumentError);
    });

    test('rejects dates that do not exist', () {
      expect(() => CalendarDay(2026, 2, 30), throwsArgumentError);
      expect(() => CalendarDay(2026, 4, 31), throwsArgumentError);
      expect(() => CalendarDay(2026, 13, 1), throwsArgumentError);
      expect(() => CalendarDay(2026, 0, 1), throwsArgumentError);
      expect(() => CalendarDay(2026, 1, 0), throwsArgumentError);
    });

    test('fromDateTime keeps the date and drops the time', () {
      expect(
        CalendarDay.fromDateTime(DateTime(2026, 3, 1, 23, 59, 59)),
        CalendarDay(2026, 3, 1),
      );
      expect(
        CalendarDay.fromDateTime(DateTime(2026, 3)),
        CalendarDay(2026, 3, 1),
      );
    });
  });

  group('addDays', () {
    test('crosses month, year and leap-day boundaries', () {
      expect(CalendarDay(2026, 1, 31).addDays(1), CalendarDay(2026, 2, 1));
      expect(CalendarDay(2026, 12, 31).addDays(1), CalendarDay(2027, 1, 1));
      expect(CalendarDay(2028, 2, 28).addDays(1), CalendarDay(2028, 2, 29));
      expect(CalendarDay(2026, 2, 28).addDays(1), CalendarDay(2026, 3, 1));
    });

    test('goes backwards with a negative number', () {
      expect(CalendarDay(2026, 3, 1).addDays(-1), CalendarDay(2026, 2, 28));
    });

    test('adding zero returns the same day', () {
      expect(CalendarDay(2026, 3, 1).addDays(0), CalendarDay(2026, 3, 1));
    });

    test('stepping one day at a time never skips or repeats a day', () {
      var current = CalendarDay(2024, 1, 1);
      for (var i = 0; i < 1500; i++) {
        final next = current.addDays(1);
        final gap = DateTime.utc(
          next.year,
          next.month,
          next.day,
        ).difference(DateTime.utc(current.year, current.month, current.day));
        expect(gap, const Duration(days: 1));
        current = next;
      }
    });
  });

  group('toDateTime', () {
    test('is local noon and round-trips on every day of 4 years', () {
      // Runs in the machine's time zone, so on a device in Cairo this
      // crosses real daylight-saving changes.
      var current = CalendarDay(2024, 1, 1);
      for (var i = 0; i < 1500; i++) {
        final dateTime = current.toDateTime();
        expect(dateTime.hour, 12);
        expect(CalendarDay.fromDateTime(dateTime), current);
        current = current.addDays(1);
      }
    });
  });

  group('text form', () {
    test('toIsoString pads month and day', () {
      expect(CalendarDay(2026, 3, 5).toIsoString(), '2026-03-05');
    });

    test('parse reads what toIsoString writes', () {
      final day = CalendarDay(2026, 11, 22);
      expect(CalendarDay.parse(day.toIsoString()), day);
    });

    test('parse rejects malformed and impossible text', () {
      for (final bad in ['abc', '2026-3-1', '2026-02-30', '2026-13-01', '']) {
        expect(
          () => CalendarDay.parse(bad),
          throwsFormatException,
          reason: bad,
        );
      }
    });

    test('text order equals chronological order', () {
      final days = [
        CalendarDay(2027, 1, 1),
        CalendarDay(2026, 12, 31),
        CalendarDay(2026, 3, 5),
        CalendarDay(2026, 3, 10),
      ];
      final chronological = [...days]..sort();
      final byText = [...days]
        ..sort((a, b) => a.toIsoString().compareTo(b.toIsoString()));
      expect(byText, chronological);
    });
  });

  group('comparison', () {
    test('equal days are equal and share a hash code', () {
      expect(CalendarDay(2026, 3, 1), CalendarDay(2026, 3, 1));
      expect(
        CalendarDay(2026, 3, 1).hashCode,
        CalendarDay(2026, 3, 1).hashCode,
      );
    });

    test('isBefore and isAfter follow the calendar', () {
      final earlier = CalendarDay(2026, 3, 1);
      final later = CalendarDay(2026, 3, 2);
      expect(earlier.isBefore(later), isTrue);
      expect(later.isAfter(earlier), isTrue);
      expect(earlier.isBefore(earlier), isFalse);
      expect(earlier.isAfter(earlier), isFalse);
    });
  });
}
