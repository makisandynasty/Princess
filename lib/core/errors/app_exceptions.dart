/// Custom exception types for structured error handling.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class SyncException extends AppException {
  const SyncException(super.message, {super.code});
}

class AlarmException extends AppException {
  const AlarmException(super.message, {super.code});
}

class PhotoCacheException extends AppException {
  const PhotoCacheException(super.message, {super.code});
}
