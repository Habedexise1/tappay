import 'exceptions.dart';
import 'failures.dart';

abstract final class ErrorMapper {
  static Failure toFailure(Object error) => switch (error) {
    NetworkException(:final message, :final code) => NetworkFailure(
      message,
      code,
    ),
    InsufficientFundsException(:final message) => ValidationFailure(
      message,
      code: 'insufficient_funds',
    ),
    AuthException(:final message, :final code) => AuthFailure(message, code),
    StorageException(:final message, :final code) => StorageFailure(
      message,
      code,
    ),
    AppException(:final message, :final code) => ServerFailure(message, code),
    _ => const ServerFailure(),
  };
}
