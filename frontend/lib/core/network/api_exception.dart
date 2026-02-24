/// API error with optional status code and server message.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.serverError,
  });

  final String message;
  final int? statusCode;
  final String? serverError;

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (status: $statusCode)' : ''}'
      '${serverError != null ? ' — $serverError' : ''}';
}
