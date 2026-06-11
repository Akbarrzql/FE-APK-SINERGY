import 'dart:convert';
import 'dart:io';

import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/feature/search/model/screen_model.dart';
import 'package:gabungyuk/core/common/http_logger.dart';
import 'package:http/http.dart' as http;

abstract class SearchRepository {
  Future<SearchModel> searchQuery(String query);
}

class SearchRepositoryImpl implements SearchRepository {
  final SharedCode _sharedCode = SharedCode();

  @override
  Future<SearchModel> searchQuery(String query) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/search?query=$query');

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    HttpLogger.logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return SearchModel.fromRawJson(response.body);
    } else {
      String message = 'Terjadi kesalahan. Silakan coba lagi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey('details')) {
          message = json['details'].toString();
        } else if (json.containsKey('message')) {
          message = json['message'].toString();
        } else if (json.containsKey('msg')) {
          message = json['msg'].toString();
        }
      } catch (_) {
        // ignore
      }

      if (response.statusCode == 400) {
        message = message.isNotEmpty ? message : 'Permintaan tidak valid. Periksa kembali input.';
      } else if (response.statusCode == 401) {
        message = 'Sesi Anda telah berakhir. Silakan masuk kembali.';
      } else if (response.statusCode >= 500) {
        message = 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
      }

      throw ApiException(message, response.statusCode);
    }
  }
}

