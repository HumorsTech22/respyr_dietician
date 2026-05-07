// lib/features/user_habits/data/exceptions/habit_exceptions.dart

/// Base API exception
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final int? httpCode;

  const AppException(this.message, {this.code, this.httpCode});

  @override
  String toString() => message;
}

/// No internet / network failure
class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection. Please check your network.'])
      : super(message, code: 'NETWORK_ERROR');
}

/// Request timed out
class TimeoutException extends AppException {
  const TimeoutException([String message = 'Request timed out. Please try again.'])
      : super(message, code: 'TIMEOUT');
}

/// 4xx — client/validation errors
class ClientException extends AppException {
  const ClientException(String message, {String? code, int? httpCode})
      : super(message, code: code, httpCode: httpCode);
}

/// 404 — resource not found
class NotFoundException extends AppException {
  const NotFoundException([String message = 'Profile not found'])
      : super(message, code: 'NOT_FOUND', httpCode: 404);
}

/// 5xx — server side
class ServerException extends AppException {
  const ServerException([String message = 'Server error. Please try again later.', int? httpCode])
      : super(message, code: 'SERVER_ERROR', httpCode: httpCode);
}

/// Bad/unparseable response
class ParseException extends AppException {
  const ParseException([String message = 'Invalid response from server'])
      : super(message, code: 'PARSE_ERROR');
}

/// Anything else
class UnknownException extends AppException {
  const UnknownException([String message = 'Something went wrong'])
      : super(message, code: 'UNKNOWN');
}