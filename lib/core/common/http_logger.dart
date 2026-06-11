import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HttpLogger {
  static void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? fields,
  }) {
    if (kDebugMode) {
      print('\n--- API REQUEST ---');
      print('Method: $method');
      print('URL: $url');
      if (headers != null) print('Headers: $headers');
      if (body != null) {
        if (body is Map || body is List) {
          print('Body: ${jsonEncode(body)}');
        } else {
          print('Body: $body');
        }
      }
      if (fields != null) print('Fields (Multipart): $fields');
      print('-------------------\n');
    }
  }

  static void logResponse(http.Response response) {
    if (kDebugMode) {
      print('\n--- API RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Method: ${response.request?.method}');
      print('URL: ${response.request?.url}');
      print('Response Body: ${response.body}');
      print('--------------------\n');
    }
  }
}
