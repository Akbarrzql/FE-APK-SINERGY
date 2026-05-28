import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/feature/home/model/detail_project_model.dart';
import 'package:gabungyuk/feature/home/model/view_project_model.dart';
import 'package:gabungyuk/feature/home/model/request_collaboration_model.dart';
import 'package:gabungyuk/feature/home/model/view_collaboration_model.dart';
import 'package:gabungyuk/feature/home/model/pending_collaboration_model.dart';
import 'package:gabungyuk/feature/collaboration/model/collaboration_profile_model.dart';
import 'package:http/http.dart' as http;

class CollaborationService {
  final SharedCode _sharedCode = SharedCode();

  void _logRequest(String method, String url, Map<String, dynamic>? data) {
    developer.log('--> $method $url');
    if (data != null) developer.log('Data: ${jsonEncode(data)}');
  }

  void _logResponse(http.Response response) {
    developer.log('<-- ${response.statusCode} ${response.request?.url}');
    developer.log('Response Body: ${response.body}');
  }

  Future<void> createProject({
    required String title,
    required String description,
    required List<String> category,
    required String status,
    required String repositoryLink,
    String? imagePath,
    DateTime? deadline,
  }) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/create/projects');

    final request = http.MultipartRequest('POST', url);
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    // Data dikirim sebagai JSON string dalam field 'data'
    final projectData = {
      "title": title,
      "description": description,
      "category": category,
      "status": status,
      "repositoryLink": repositoryLink,
      if (deadline != null) "deadline": deadline.toIso8601String(),
    };
    request.fields['data'] = jsonEncode(projectData);

    // File dikirim dalam field 'pictureProject'
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath('pictureProject', imagePath));
      }
    }

    _logRequest('POST', url.toString(), projectData);
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _logResponse(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Terjadi kesalahan saat membuat proyek.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<void> updateCollaboration({
    required String id,
    required String title,
    required String description,
    required List<String> category,
    required String status,
    required String repositoryLink,
    String? imagePath,
    DateTime? deadline,
  }) async {
    final token = await _sharedCode.getAuthToken();
    final apiUrl = Uri.parse('${ApiConfig.baseUrl}/api/v1/projects/$id');

    final request = http.MultipartRequest('PATCH', apiUrl);
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    final projectData = {
      "title": title,
      "description": description,
      "category": category,
      "status": status,
      "repositoryLink": repositoryLink,
      if (deadline != null) "deadline": deadline.toIso8601String(),
    };
    request.fields['data'] = jsonEncode(projectData);

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        request.files.add(
            await http.MultipartFile.fromPath('pictureProject', imagePath));
      }
    }

    _logRequest('PATCH', apiUrl.toString(), projectData);
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _logResponse(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Terjadi kesalahan saat memperbarui proyek.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<void> deleteCollaboration({required String id}) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/delete/projects');

    _logRequest('DELETE', url.toString(), {
      "projectId": int.tryParse(id) ?? id,
    });
    final response = await http.delete(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        "projectId": int.tryParse(id) ?? id,
      }),
    );
    _logResponse(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Gagal menghapus proyek.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<List<Datum>> getAllProjects() async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/projects');

    _logRequest('GET', url.toString(), null);
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final projectModel = viewProjectModelFromJson(response.body);
      return projectModel.data;
    } else {
      String message = 'Gagal mengambil data proyek.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<List<Datum>> getMyProjects() async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/projects');

    _logRequest('GET', url.toString(), null);
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final projectModel = viewProjectModelFromJson(response.body);
      return projectModel.data;
    } else {
      String message = 'Gagal mengambil data proyek.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<DetailProjectModel> getProjectDetail(int projectId) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/api/v1/collaboration/detail/project/$projectId/');

    _logRequest('GET', url.toString(), null);
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return detailProjectModelFromJson(response.body);
    } else {
      String message = 'Gagal mengambil detail proyek.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<ViewCollaborationModel?> checkJoinStatus(int projectId) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/collaboration/$projectId');

    _logRequest('GET', url.toString(), null);
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return viewCollaborationModelFromJson(response.body);
    } else if (response.statusCode == 404) {
      return null; // Not requested yet
    } else {
      return null;
    }
  }

  Future<RequestCollaborationModel> requestJoin(int projectId) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/collaboration/request/$projectId');

    _logRequest('POST', url.toString(), null);
    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return requestCollaborationModelFromJson(response.body);
    } else {
      String message = 'Gagal mengirim permintaan bergabung.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<PendingCollaborationModel> getPendingRequests(int projectId) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/collaboration/project/$projectId/pending');

    _logRequest('GET', url.toString(), null);
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return pendingCollaborationModelFromJson(response.body);
    } else {
      String message = 'Gagal mengambil permintaan tertunda.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<void> collaborationAction({
    required int projectId,
    required int userId,
    required String action,
  }) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/collaboration/action');

    final body = {
      "projectId": projectId,
      "userId": userId,
      "action": action.toUpperCase(),
    };

    _logRequest('POST', url.toString(), body);
    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );
    _logResponse(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Gagal memproses aksi kolaborasi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  Future<CollaborationProfileModel> getCollaborationDashboard() async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/collaboration/dashboard');

    _logRequest('GET', url.toString(), null);
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return collaborationProfileModelFromJson(response.body);
    } else {
      String message = 'Gagal mengambil data dashboard kolaborasi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }
}
