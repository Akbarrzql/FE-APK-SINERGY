import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/feature/profile/model/profile_model.dart';
import 'package:gabungyuk/feature/profile/model/edit_profile_model.dart';
import 'package:http/http.dart' as http;

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();
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
        if (json.containsKey('message')) {
          message = json['message'].toString();
        } else if (json.containsKey('msg')) {
          message = json['msg'].toString();
        } else if (json.containsKey('error')) {
          message = json['error'].toString();
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

   Future<EditProfileModel> updateProfile(Map<String, dynamic> body, {File? profileImageFile}) async {
     final token = await _sharedCode.getAuthToken();
     final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/update/users/current');

    // If a file is picked, upload as multipart/form-data so backend can store file and return URL.
    http.Response response;
    if (profileImageFile != null && profileImageFile.existsSync()) {
      final request = http.MultipartRequest('PUT', url)
        ..headers['Authorization'] = 'Bearer $token';

      // Add text fields
      body.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });

      // Attach file
      final stream = http.ByteStream(profileImageFile.openRead());
      final length = await profileImageFile.length();
      final multipartFile = http.MultipartFile(
        'profilePicture',
        stream,
        length,
        filename: profileImageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      if (kDebugMode) debugPrint('PROFILE UPDATE DEBUG: sending multipart with file=${profileImageFile.path} size=$length');

      final streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    } else {
      // No file: send JSON body
      response = await http.put(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode(body),
      );
    }

    // Note: response assigned above (multipart or JSON)

     if (response.statusCode >= 200 && response.statusCode < 300) {
       final editModel = editProfileModelFromJson(response.body);
       // If server returns new token, update session
       try {
         if (editModel.data.token.isNotEmpty) {
           await _sharedCode.saveAuthSession(
             token: editModel.data.token,
             expiredAt: editModel.data.expiredAt,
           );
         }
       } catch (_) {}
       return editModel;
     } else {
       String message = 'Terjadi kesalahan. Silakan coba lagi.';
       try {
         final Map<String, dynamic> json = jsonDecode(response.body);
         if (json.containsKey('message')) {
           message = json['message'].toString();
         } else if (json.containsKey('msg')) {
           message = json['msg'].toString();
         } else if (json.containsKey('error')) {
           message = json['error'].toString();
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
}

