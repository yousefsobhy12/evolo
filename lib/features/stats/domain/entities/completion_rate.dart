import 'package:equatable/equatable.dart';

/// Completed days out of counted days.
///
/// It keeps both numbers instead of a ratio, so totals can add them up. The
/// average of percentages would let a habit with 1 counted day weigh as much
/// as a habit with 30.
final class CompletionRate extends Equatable {
  const new({required this.completedDays, required this.dueDays})
    : assert(
        completedDays >= 0 && completedDays <= dueDays,
        'completedDays must be between 0 and dueDays',
      );

  static const empty = CompletionRate(completedDays: 0, dueDays: 0);

  final int completedDays;
  final int dueDays;

  /// 0..100, rounded down, so 100 means every counted day was completed.
  /// Null when no day is counted yet: that is "no data", not 0%.
  ///
  /// Integer division on purpose: no floating-point error.
  int? get percent => dueDays == 0 ? null : completedDays * 100 ~/ dueDays;

  CompletionRate operator +(CompletionRate other) => CompletionRate(
    completedDays: completedDays + other.completedDays,
    dueDays: dueDays + other.dueDays,
  );

  @override
  List<Object> get props => [completedDays, dueDays];
}
