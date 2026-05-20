import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:gabungyuk/feature/auth/service/firebase_token_helper.dart';

/// 🚀 Firebase-Aware HTTP Client
///
/// Extension untuk http.Client yang otomatis menambahkan Firebase ID Token
/// ke setiap request sebagai "Authorization: Bearer <token>" header
class FirebaseHttpClient extends http.BaseClient {
  final http.Client _inner;

  FirebaseHttpClient({http.Client? innerClient})
      : _inner = innerClient ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Get Firebase token
    final token = await FirebaseTokenHelper.getTokenRefreshed();

    // Add Authorization header jika token ada
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';

      if (kDebugMode) {
        debugPrint(
          'FirebaseHttpClient: Added token to request: ${request.url.toString().substring(0, 50)}',
        );
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          'FirebaseHttpClient: No token available for request: ${request.url.toString().substring(0, 50)}',
        );
      }
    }

    try {
      // Send request
      final response = await _inner.send(request);

      // Handle 401 Unauthorized - token mungkin expired
      if (response.statusCode == 401) {
        if (kDebugMode) {
          debugPrint(
            'FirebaseHttpClient: Got 401, trying refresh and retry',
          );
        }

        // Try refresh token dan retry
        final newToken = await FirebaseTokenHelper.getTokenRefreshed();
        if (newToken != null && newToken != token) {
          // Create new request dengan token baru
          final retryRequest = _copyRequest(request);
          retryRequest.headers['Authorization'] = 'Bearer $newToken';

          if (kDebugMode) {
            debugPrint('FirebaseHttpClient: Retrying with refreshed token');
          }

          return _inner.send(retryRequest);
        }
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirebaseHttpClient: Error sending request: $e');
      }
      rethrow;
    }
  }

  /// Copy request untuk retry
  http.BaseRequest _copyRequest(http.BaseRequest request) {
    http.BaseRequest requestCopy;

    if (request is http.Request) {
      requestCopy = http.Request(request.method, request.url)
        ..encoding = request.encoding
        ..bodyBytes = request.bodyBytes;
    } else if (request is http.MultipartRequest) {
      requestCopy = http.MultipartRequest(request.method, request.url)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
    } else if (request is http.StreamedRequest) {
      throw Exception('Cannot copy StreamedRequest');
    } else {
      throw Exception('Cannot copy ${request.runtimeType}');
    }

    requestCopy
      ..persistentConnection = request.persistentConnection
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..headers.addAll(request.headers);

    return requestCopy;
  }
}

/// 🎯 Usage Example
///
/// // Ganti http.Client dengan FirebaseHttpClient di app Anda
/// final httpClient = FirebaseHttpClient();
///
/// // Semua request otomatis punya Firebase token!
/// final response = await httpClient.get(
///   Uri.parse('https://api.example.com/user'),
/// );
///
/// // Jika token expired, otomatis retry dengan token baru

