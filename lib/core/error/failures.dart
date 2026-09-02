import 'package:equatable/equatable.dart';

/// Functional error hierarchy for the app.
///
/// Usecases and repositories surface these via `Either<Failure, T>`.
/// Concrete subclasses are created by repository implementations when a data
/// source call fails; presentation layers map them to user-facing messages.
sealed class Failure extends Equatable {
  const Failure({required this.message});

  /// A human-readable message suitable for showing to the user.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Something went wrong reading/writing a local cache (JSON file, etc.).
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Local data could not be read.'});
}

/// The requested item / collection does not exist.
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'The item was not found.'});
}

/// User input did not pass validation.
class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'The provided value is invalid.'});
}

/// Any other unexpected failure that could not be categorised.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'Something went wrong.'});
}