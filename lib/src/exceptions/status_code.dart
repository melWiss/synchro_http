import 'package:http/http.dart';

class StatusException implements Exception {
  final String message;
  final Response? data;
  final int statusCode;

  StatusException({
    this.message = "STATUS_CODE_EXCEPTION",
    this.data,
    required this.statusCode,
  });

  @override
  String toString() {
    return message;
  }
}
