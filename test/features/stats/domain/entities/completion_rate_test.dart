import 'package:evolo/features/stats/domain/entities/completion_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int? percent(int completed, int due) =>
      CompletionRate(completedDays: completed, dueDays: due).percent;

  test('no counted day means no percent, not 0%', () {
    expect(CompletionRate.empty.percent, isNull);
  });

  test('rounds down', () {
    expect(percent(2, 3), 66);
    expect(percent(199, 200), 99);
  });

  test('the ends are exact', () {
    expect(percent(0, 4), 0);
    expect(percent(3, 3), 100);
  });

  test('adding sums both numbers', () {
    const one = CompletionRate(completedDays: 1, dueDays: 1);
    const other = CompletionRate(completedDays: 1, dueDays: 4);

    expect(one + other, const CompletionRate(completedDays: 2, dueDays: 5));
  });
}
