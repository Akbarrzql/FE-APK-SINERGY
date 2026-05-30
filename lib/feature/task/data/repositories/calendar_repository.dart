import 'dart:convert';
import 'dart:io';
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/feature/task/data/models/calendar_event_model.dart';
import 'package:http/http.dart' as http;

abstract class CalendarRepository {
  Future<CalendarEventModel> fetchCalendarEvents(int year, int month);
  Future<void> markEventAsDone(int projectId);
}

class CalendarRepositoryImpl implements CalendarRepository {
  final SharedCode _sharedCode = SharedCode();

  @override
  Future<CalendarEventModel> fetchCalendarEvents(int year, int month) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/calendar/filter?year=$year&month=$month');

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return calendarEventModelFromJson(response.body);
    } else {
      String message = 'Gagal mengambil data kalender.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  @override
  Future<void> markEventAsDone(int projectId) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/calendar/done');

    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({'projectId': projectId}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Gagal menyelesaikan event.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }
}
