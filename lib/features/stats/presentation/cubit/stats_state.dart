import 'package:equatable/equatable.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/features/stats/domain/entities/stats_period.dart';
import 'package:evolo/features/stats/domain/entities/stats_report.dart';

enum StatsStatus { loading, success, failure }

/// Everything the statistics screen draws. One class, so the selected
/// [period] survives Loading and Error.
final class StatsState extends Equatable {
  const new({
    this.period = StatsPeriod.week,
    this.status = StatsStatus.loading,
    this.report,
    this.failure,
  });

  /// What the toggle shows.
  final StatsPeriod period;

  final StatsStatus status;

  /// The numbers of [period]. Set only when [status] is success.
  final StatsReport? report;

  /// Why loading failed. Set only when [status] is failure.
  final Failure? failure;

  /// Loaded, but there is no habit to show numbers for. A period with no
  /// counted day is not empty: its bars show "no data".
  bool get isEmpty => report?.habits.isEmpty ?? false;

  @override
  List<Object?> get props => [period, status, report, failure];
}
