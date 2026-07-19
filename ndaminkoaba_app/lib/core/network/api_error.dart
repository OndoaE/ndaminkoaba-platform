import 'package:dio/dio.dart';

/// The backend's global exception filter wraps every error as
/// `{ success: false, statusCode, path, error: { message, error, statusCode }, timestamp }`,
/// where `message` can be a string or (for validation errors) a list of
/// strings. This extracts a single human-readable string from that shape.
String extractErrorMessage(DioException e, {String fallback = 'Something went wrong. Please try again.'}) {
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
