import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/feature/notification/model/notification_model.dart';
import 'package:gabungyuk/feature/notification/model/unread_notification_model.dart';

class NotificationService {
  final SharedCode _sharedCode = SharedCode();

  void _logRequest(String method, String url, Map<String, dynamic>? data) {
    developer.log('--> $method $url');
    if (data != null) developer.log('Data: ${jsonEncode(data)}');
  }

  void _logResponse(http.Response response) {
    developer.log('<-- ${response.statusCode} ${response.request?.url}');
    developer.log('Response Body: ${response.body}');
  }

  Future<List<NotificationData>> getAllNotifications() async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications');

    _logRequest('GET', url.toString(), null);
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final model = notificationModelFromJson(response.body);
      return model.data;
    } else {
      String message = 'Gagal mengambil notifikasi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<UnreadNotificationData> getUnreadNotifications() async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/unread');

    _logRequest('GET', url.toString(), null);
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final model = unreadNotificationModelFromJson(response.body);
      return model.data;
    } else {
      String message = 'Gagal mengambil jumlah notifikasi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<MarkAsReadData> markAsRead(int notificationId) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/$notificationId/read');

    _logRequest('PATCH', url.toString(), null);
    final response = await http.patch(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final model = markAsReadModelFromJson(response.body);
      return model.data;
    } else {
      String message = 'Gagal memperbarui status notifikasi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<void> markAllAsRead() async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/read-all');

    _logRequest('PATCH', url.toString(), null);
    final response = await http.patch(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      String message = 'Gagal menandai semua notifikasi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }
}
