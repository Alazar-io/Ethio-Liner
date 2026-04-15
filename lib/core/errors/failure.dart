import 'package:equatable/equatable.dart';

/// Represents a failure in the application.
///
/// Used as a return type in Result/Either patterns to represent
/// errors without throwing exceptions. Extends [Equatable] for
/// value-based equality comparison in tests.
class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
  });

  /// User-facing error message.
  final String message;

  /// Optional error code for programmatic handling.
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Network failure.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Unable to connect. Please check your internet connection.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Server failure (5xx).
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Something went wrong. Please try again later.',
    super.code = 'SERVER_ERROR',
  });
}

/// Authentication failure.
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed. Please log in again.',
    super.code = 'AUTH_ERROR',
  });
}

/// Validation failure.
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Please check your input and try again.',
    super.code = 'VALIDATION_ERROR',
  });
}

/// Not found failure.
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code = 'NOT_FOUND',
  });
}

/// Conflict failure (e.g., seat already reserved).
class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message = 'This resource is no longer available.',
    super.code = 'CONFLICT',
  });
}
