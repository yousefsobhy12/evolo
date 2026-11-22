import 'dart:async';

import 'package:evolo/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

/// The only place in the app that catches. Nothing thrown inside [action]
/// can leave a repository: it comes out as a `Left`.
Future<Either<Failure, T>> guard<T>(
  Future<Either<Failure, T>> Function() action,
) async {
  try {
    return await action();
  } on Object catch (error) {
    return Left(_toFailure(error));
  }
}

extension GuardedStream<T> on Stream<T> {
  /// Maps every event with [map]. Stream errors and exceptions thrown by
  /// [map] both become `Left`, so the Cubit only ever needs `fold`.
  Stream<Either<Failure, R>> mapToEither<R>(R Function(T event) map) {
    return transform(
      StreamTransformer<T, Either<Failure, R>>.fromHandlers(
        handleData: (data, sink) {
          try {
            sink.add(Right(map(data)));
          } on Object catch (error) {
            sink.add(Left(_toFailure(error)));
          }
        },
        handleError: (error, _, sink) => sink.add(Left(_toFailure(error))),
      ),
    );
  }
}

/// Same split as S4: `Exception` => database problem, anything else =>
/// a bug we did not expect.
Failure _toFailure(Object error) => error is Exception
    ? DatabaseFailure(cause: error)
    : UnexpectedFailure(cause: error);
