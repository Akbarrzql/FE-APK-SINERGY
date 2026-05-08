import 'dart:convert';
import 'dart:developer' as developer;

import 'package:gabungyuk/core/common/auth_session_manager.dart';
import 'package:http/http.dart' as http;

class AuthHttpClient {
  AuthHttpClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  void _logRequest(String method, Uri url, {Map<String, String>? headers, Object? body}) {
    developer.log('--> $method $url');
    if (headers != null) developer.log('Headers: $headers');
    if (body != null) developer.log('Body: $body');
  }

  void _logResponse(http.Response response) {
    developer.log('<-- ${response.statusCode} ${response.request?.url}');
    developer.log('Response: ${response.body}');
  }

  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool handleUnauthorized = true,
  }) async {
    _logRequest('GET', url, headers: headers);
    final response = await _client.get(url, headers: headers);
    _logResponse(response);
    await _handleUnauthorized(response, handleUnauthorized);
    return response;
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool handleUnauthorized = true,
  }) async {
    _logRequest('POST', url, headers: headers, body: body);
    final response = await _client.post(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    _logResponse(response);
    await _handleUnauthorized(response, handleUnauthorized);
    return response;
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool handleUnauthorized = true,
  }) async {
    _logRequest('PUT', url, headers: headers, body: body);
    final response = await _client.put(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    _logResponse(response);
    await _handleUnauthorized(response, handleUnauthorized);
    return response;
  }

  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool handleUnauthorized = true,
  }) async {
    _logRequest('DELETE', url, headers: headers, body: body);
    final response = await _client.delete(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    _logResponse(response);
    await _handleUnauthorized(response, handleUnauthorized);
    return response;
  }

  Future<void> close() async {
    _client.close();
  }

  Future<void> _handleUnauthorized(
    http.Response response,
    bool handleUnauthorized,
  ) async {
    if (handleUnauthorized && response.statusCode == 401) {
      await AuthSessionManager.instance.forceLogout();
    }
  }
}

