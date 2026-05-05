import 'dart:convert';
import 'dart:io';

import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:http/http.dart' as http;

class CollaborationService {
  /// Create a new collaboration. If [imagePath] is provided, it will be
  /// uploaded as multipart file under field name `image`.
  Future<void> createCollaboration({
    required String title,
    required String description,
    required String category,
    required String status,
    required String repositoryLink,
    required String url,
    String? imagePath,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/collaborations');

    final request = http.MultipartRequest('POST', uri);
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = category;
    request.fields['status'] = status;
    request.fields['repositoryLink'] = repositoryLink;
    request.fields['url'] = url;

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Terjadi kesalahan. Silakan coba lagi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey('message')) message = json['message'].toString();
      } catch (_) {}

      throw ApiException(AuthUiHelper.toIndonesianMessage(message), response.statusCode);
    }
  }

  /// Update existing collaboration by id. If [imagePath] provided, it will
  /// replace existing image.
  Future<void> updateCollaboration({
    required String id,
    required String title,
    required String description,
    required String category,
    required String status,
    required String repositoryLink,
    required String url,
    String? imagePath,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/collaborations/$id');

    final request = http.MultipartRequest('PUT', uri);
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = category;
    request.fields['status'] = status;
    request.fields['repositoryLink'] = repositoryLink;
    request.fields['url'] = url;

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Terjadi kesalahan. Silakan coba lagi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey('message')) message = json['message'].toString();
      } catch (_) {}

      throw ApiException(AuthUiHelper.toIndonesianMessage(message), response.statusCode);
    }
  }

  /// Delete collaboration by id
  Future<void> deleteCollaboration({required String id}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/collaborations/$id');
    final response = await http.delete(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Gagal menghapus kolaborasi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey('message')) message = json['message'].toString();
      } catch (_) {}

      throw ApiException(AuthUiHelper.toIndonesianMessage(message), response.statusCode);
    }
  }
}

