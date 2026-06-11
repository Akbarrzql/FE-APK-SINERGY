import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/feature/portofolio/data/models/portofolio_model.dart';
import 'package:gabungyuk/feature/portofolio/data/models/add_portofolio_models.dart';
import 'package:gabungyuk/feature/portofolio/data/models/edit_portofolio_model.dart';
import 'package:gabungyuk/feature/portofolio/data/models/delete_portofolio_model.dart';
import 'package:gabungyuk/core/common/http_logger.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PortofolioService {
  final SharedCode _sharedCode = SharedCode();

  void _logRequest(String method, String url, Map<String, dynamic>? data) {
    HttpLogger.logRequest(method: method, url: url, body: data);
  }

  void _logResponse(http.Response response) {
    HttpLogger.logResponse(response);
  }

  Future<PortofolioModel> getPortfolios() async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/portfolio');

    _logRequest('GET', url.toString(), null);
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PortofolioModel.fromRawJson(response.body);
    } else {
      String message = 'Gagal mengambil data portfolio.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<PortofolioModel> getPortfoliosByUserId(int userId) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/portfolio/$userId');

    _logRequest('GET', url.toString(), null);
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PortofolioModel.fromRawJson(response.body);
    } else {
      String message = 'Gagal mengambil data portfolio pengguna.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<AddPortofolioModels> createPortfolio({
    required String title,
    required String description,
    required String fileUrl,
    String? imagePath,
  }) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/create/portfolio');

    final request = http.MultipartRequest('POST', url);
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    // Metadata dikirim sebagai JSON string dalam field 'data'
    request.fields['data'] = jsonEncode({
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
    });

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        final extension = imagePath.split('.').last.toLowerCase();
        final mimeType = extension == 'png' ? 'png' : 'jpeg';
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', mimeType),
        ));
      }
    }

    _logRequest('POST (Multipart)', url.toString(), {
      "title": title,
      "description": description,
      "fileUrl": fileUrl,
      "imagePath": imagePath,
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AddPortofolioModels.fromRawJson(response.body);
    } else {
      String message = 'Gagal menambahkan portfolio.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<EditPortofolioModel> editPortfolio({
    required int portfolioId,
    required String title,
    required String description,
    required String fileUrl,
    String? imagePath,
  }) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/edit/portfolio/$portfolioId');

    final request = http.MultipartRequest('PUT', url);
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    // Metadata dikirim sebagai JSON string dalam field 'data'
    request.fields['data'] = jsonEncode({
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
    });

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        final extension = imagePath.split('.').last.toLowerCase();
        final mimeType = extension == 'png' ? 'png' : 'jpeg';
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', mimeType),
        ));
      }
    }

    _logRequest('PUT (Multipart)', url.toString(), {
      "portfolioId": portfolioId,
      "title": title,
      "description": description,
      "fileUrl": fileUrl,
      "imagePath": imagePath,
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return EditPortofolioModel.fromRawJson(response.body);
    } else {
      String message = 'Gagal mengubah portfolio.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<DeletePortofolioModel> deletePortfolio(int id) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/delete/portfolio');

    final bodyData = {'portfolioId': id};
    _logRequest('DELETE', url.toString(), bodyData);

    final response = await http.delete(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(bodyData),
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return DeletePortofolioModel.fromRawJson(response.body);
    } else {
      String message = 'Gagal menghapus portfolio.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }
}
