import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/feature/profile/model/profile_model.dart';
import 'package:gabungyuk/feature/profile/model/view_profile_model.dart';
import 'package:gabungyuk/core/common/http_logger.dart';
import 'package:http/http.dart' as http;
import '../model/edit_profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();
  Future<ViewProfileModel> getViewProfile();
  Future<ViewProfileModel> getViewProfileById(int userId);
  Future<EditProfileModel> updateProfile(Map<String, dynamic> body, {File? profileImageFile});
}

class ProfileRepositoryImpl implements ProfileRepository {
  final SharedCode _sharedCode = SharedCode();

  @override
  Future<ProfileModel> getProfile() async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/profile');

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    return _handleResponse(response, (body) => profileModelFromJson(body));
  }

  @override
  Future<ViewProfileModel> getViewProfile() async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/profile');

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    return _handleResponse(response, (body) => viewProfileModelFromJson(body));
  }

  @override
  Future<ViewProfileModel> getViewProfileById(int userId) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/$userId');

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    return _handleResponse(response, (body) => viewProfileModelFromJson(body));
  }

  @override
  Future<EditProfileModel> updateProfile(Map<String, dynamic> body,
      {File? profileImageFile}) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/update/users/current');

    try {
      if (profileImageFile == null) {
        // If no file, use JSON endpoint (application/json)
        HttpLogger.logRequest(
          method: 'PATCH',
          url: url.toString(),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
          body: body,
        );

        final response = await http.patch(
          url,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
          body: jsonEncode(body),
        );

        return _handleResponse(response, (b) => editProfileModelFromJson(b));
      } else {
        // If there's a file, use MultipartRequest (multipart/form-data)
        // Backend expects JSON in "data" part and file in "profilePicture" part
        var request = http.MultipartRequest('PATCH', url);
        request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

        // Masukkan data JSON ke field 'data'
        request.fields['data'] = jsonEncode(body);

        // Tambahkan file gambar
        request.files.add(await http.MultipartFile.fromPath(
          'profilePictureFile',
          profileImageFile.path,
        ));

        HttpLogger.logRequest(
          method: 'PATCH',
          url: url.toString(),
          headers: request.headers,
          fields: request.fields,
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        return _handleResponse(response, (b) => editProfileModelFromJson(b));
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      if (kDebugMode) {
        print('Update Profile Exception: $e');
      }
      throw ApiException('Gagal memperbarui profil: ${e.toString()}', 500);
    }
  }

  T _handleResponse<T>(http.Response response, T Function(String) mapper) {
    HttpLogger.logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return mapper(response.body);
      } catch (e) {
        if (kDebugMode) print('Mapping Error: $e');
        throw ApiException('Gagal memproses data dari server', response.statusCode);
      }
    }

    String message = 'Terjadi kesalahan (${response.statusCode}).';
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      // Try various common error fields from backend
      message = json['details']?.toString() ??
                json['message']?.toString() ??
                json['msg']?.toString() ??
                message;
    } catch (_) {}

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
