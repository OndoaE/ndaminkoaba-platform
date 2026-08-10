import 'package:dio/dio.dart';

/// The backend's global exception filter wraps every error as
/// `{ success: false, statusCode, path, error: { message, error, statusCode }, timestamp }`,
/// where `message` can be a string or (for validation errors) a list of
/// strings. This extracts a single human-readable string from that shape.
String extractErrorMessage(
  DioException e, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  final data = e.response?.data;
  if (data is! Map) return fallback;

  final error = data['error'];
  dynamic message;

  if (error is Map) {
    message = error['message'];
  } else if (error is String) {
    message = error;
  }

  message ??= data['message'];

  if (message is List) {
    return message.join('\n');
  }
  if (message is String && message.isNotEmpty) {
    return message;
  }

  return fallback;
}

/// True when [e] represents "the request never reached the server" (device
/// offline, DNS failure, timed out establishing/receiving a connection)
/// rather than a real server-side error. Screens use this to decide between
/// falling back to a downloaded copy (if one exists) versus showing the
/// existing generic error state — `extractErrorMessage` above only handles
/// the case where `e.response?.data` exists, so it's silent on exactly the
/// failures this checks for.
bool isConnectivityFailure(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.transformTimeout:
      return true;
    case DioExceptionType.badResponse:
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return e.response == null;
  }
}
