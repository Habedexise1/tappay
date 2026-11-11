/// Domain failure models for clean architecture.
sealed class Failure {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'A server error occurred. Please try again.',
    String? code,
  ]) : super(code: code);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection detected.',
    String? code,
  ]) : super(code: code);
}

class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Authentication failed. Invalid PIN or credentials.',
    String? code,
  ]) : super(code: code);
}

class BiometricFailure extends Failure {
  const BiometricFailure([
    super.message = 'Biometric verification cancelled or unavailable.',
    String? code,
  ]) : super(code: code);
}

class StorageFailure extends Failure {
  const StorageFailure([
    super.message = 'Could not access secure storage.',
    String? code,
  ]) : super(code: code);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}
