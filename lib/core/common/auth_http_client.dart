import 'dart:convert';

import 'package:gabungyuk/core/common/auth_session_manager.dart';
import 'package:http/http.dart' as http;

class AuthHttpClient {
  AuthHttpClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool handleUnauthorized = true,
  }) async {
    final response = await _client.get(url, headers: headers);
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
    final response = await _client.post(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
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
    final response = await _client.put(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
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
    final response = await _client.delete(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
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

