import 'dart:convert';
import 'dart:io';
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:http/http.dart' as http;
import '../models/recap_model.dart';

abstract class RecapRepository {
  Future<RecapModel> getActivityRecap();
}

class RecapRepositoryImpl implements RecapRepository {
  final SharedCode _sharedCode = SharedCode();

  @override
  Future<RecapModel> getActivityRecap() async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/activity-logs/recap');

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return recapModelFromJson(response.body);
    } else {
      String message = 'Terjadi kesalahan saat mengambil recap aktivitas.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }
}
