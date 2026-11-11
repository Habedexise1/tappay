/// Custom app exceptions.
class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (${code ?? "no_code"})';
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Server encountered an unexpected error.',
    String? code,
  ]) : super(code: code);
}

class AuthException extends AppException {
  const AuthException([
    super.message = 'Authentication failed.',
    String? code,
  ]) : super(code: code);
}

class StorageException extends AppException {
  const StorageException([
    super.message = 'Storage operation failed.',
    String? code,
  ]) : super(code: code);
}
