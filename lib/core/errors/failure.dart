import 'package:equatable/equatable.dart';

/// Why a [ValidationFailure] happened. The UI maps each reason to a
/// localized message, so no user-facing text lives in the domain.
enum ValidationReason {
  nameEmpty,
  nameTooLong,
  invalidTarget,
  noDaysSelected,
  negativeCount,
}

/// Every error the domain can report. `sealed` makes `switch` exhaustive,
/// so adding a new Failure forces the UI mapping to be updated.
sealed class Failure extends Equatable {
  const new({this.cause});

  /// The original error, for logs only. Not part of equality.
  final Object? cause;

  @override
  List<Object?> get props => const [];
}

final class DatabaseFailure extends Failure {
  const new({super.cause});
}

final class NotFoundFailure extends Failure {
  const new();
}

final class ValidationFailure extends Failure {
  const new(this.reason);

  final ValidationReason reason;

  @override
  List<Object?> get props => [reason];
}

final class UnexpectedFailure extends Failure {
  const new({super.cause});
}
