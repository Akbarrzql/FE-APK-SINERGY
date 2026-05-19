import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/feature/profile/model/profile_model.dart';
import 'package:gabungyuk/feature/profile/model/view_profile_model.dart';
import 'package:http/http.dart' as http;

import '../model/edit_profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();
  Future<ViewProfileModel> getViewProfile();
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final profile = profileModelFromJson(response.body);
      return profile;
    } else {
      String message = 'Terjadi kesalahan. Silakan coba lagi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey('details')) {
          // prefer details when available (server may include SQL error info here)
          message = json['details'].toString();
        } else if (json.containsKey('message')) {
          message = json['message'].toString();
        } else if (json.containsKey('msg')) {
          message = json['msg'].toString();
        } else if (json.containsKey('details')) {
          message = json['details'].toString();
        }
      } catch (_) {
        // ignore
      }

      if (response.statusCode == 400) {
        print('Bad request response: ${response.body}');
        message = message.isNotEmpty ? message : 'Permintaan tidak valid. Periksa kembali input.';
      } else if (response.statusCode == 401) {
        print('Unauthorized response: ${response.body}');
        message = 'Sesi Anda telah berakhir. Silakan masuk kembali.';
      } else if (response.statusCode >= 500) {
        print('Server error response: ${response.body}');
        message = 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
      }

      throw ApiException(message, response.statusCode);
    }
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final profile = viewProfileModelFromJson(response.body);
      return profile;
    } else {
      String message = 'Terjadi kesalahan. Silakan coba lagi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['msg'] ?? json['details'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

   Future<EditProfileModel> updateProfile(Map<String, dynamic> body, {File? profileImageFile}) async {
     final token = await _sharedCode.getAuthToken();
     final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/update/users/current');

    try {
      final request = http.MultipartRequest('PATCH', url);
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

      // Backend expects 'data' as a JSON string in a RequestPart (New Specification)
      if (body.isNotEmpty) {
        request.fields['data'] = jsonEncode(body);
      }

      // Backend expects 'profilePicture' as a MultipartFile in a RequestPart
      if (profileImageFile != null) {
        final stream = http.ByteStream(profileImageFile.openRead());
        final length = await profileImageFile.length();
        
        final multipartFile = http.MultipartFile(
          'profilePicture',
          stream,
          length,
          filename: profileImageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      if (kDebugMode) {
        debugPrint('PROFILE UPDATE DEBUG: sending Multipart PATCH to $url');
        debugPrint('PROFILE UPDATE DEBUG: fields: ${request.fields}');
        debugPrint('PROFILE UPDATE DEBUG: files: ${request.files.map((f) => f.field).toList()}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode)
        debugPrint('PROFILE UPDATE DEBUG: response body: ${response.body}');


      if (response.statusCode >= 200 && response.statusCode < 300) {
        final editModel = editProfileModelFromJson(response.body);
        
        // Note: We no longer save the token from the backend response here 
        // because we are now using Firebase ID Token as the primary auth session.

        return editModel;
      } else {
        String message = 'Terjadi kesalahan. Silakan coba lagi.';
        try {
          final Map<String, dynamic> json = jsonDecode(response.body);
          message = json['message'] ?? json['msg'] ?? json['details'] ?? message;
        } catch (_) {}
        throw ApiException(message, response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal memperbarui profil: $e', 500);
    }
   }
}

