/// Application exception types.
///
/// Provides typed exceptions for different failure scenarios
/// throughout the application. Each exception type carries a
/// user-friendly message and optional technical details.
class AppException implements Exception {
  const AppException({
    required this.message,
    this.details,
    this.stackTrace,
  });

  /// User-facing error message.
  final String message;

  /// Technical details for debugging (not shown to users).
  final String? details;

  /// Stack trace when available.
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: $message';
}

/// Network-related exception (no internet, timeout, etc.).
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Unable to connect. Please check your internet connection.',
    super.details,
    super.stackTrace,
  });
}

/// Server-side error (5xx responses).
class ServerException extends AppException {
  const ServerException({
    super.message = 'Something went wrong on our end. Please try again later.',
    this.statusCode,
    super.details,
    super.stackTrace,
  });

  final int? statusCode;
}

/// Authentication error (invalid credentials, expired token).
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed. Please log in again.',
    super.details,
    super.stackTrace,
  });
}

/// Authorization error (insufficient permissions).
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.details,
    super.stackTrace,
  });
}

/// Validation error (invalid input).
class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Please check your input and try again.',
    this.fieldErrors,
    super.details,
    super.stackTrace,
  });

  /// Per-field validation errors (e.g., {"email": "Invalid email format"}).
  final Map<String, String>? fieldErrors;
}

/// Resource not found (404).
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.details,
    super.stackTrace,
  });
}

/// Seat/resource conflict (e.g., seat already reserved).
class ConflictException extends AppException {
  const ConflictException({
    super.message = 'This resource is no longer available. Please try again.',
    super.details,
    super.stackTrace,
  });
}

/// Reservation expired.
class ReservationExpiredException extends AppException {
  const ReservationExpiredException({
    super.message =
        'Your reservation has expired. Please select your seats again.',
    super.details,
    super.stackTrace,
  });
}

/// Payment failure.
class PaymentException extends AppException {
  const PaymentException({
    super.message = 'Payment could not be processed. Please try again.',
    super.details,
    super.stackTrace,
  });
}
