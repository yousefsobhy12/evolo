import 'package:evolo/features/habits/presentation/utils/greeting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Greeting at(int hour, [int minute = 0]) =>
      Greeting.at(DateTime(2026, 11, 26, hour, minute));

  test('morning is from 5:00 to 11:59', () {
    expect(at(5), Greeting.morning);
    expect(at(11, 59), Greeting.morning);
  });

  test('afternoon is from 12:00 to 16:59', () {
    expect(at(12), Greeting.afternoon);
    expect(at(16, 59), Greeting.afternoon);
  });

  test('evening covers the rest, including after midnight', () {
    expect(at(17), Greeting.evening);
    expect(at(0), Greeting.evening);
    expect(at(4, 59), Greeting.evening);
  });
}
