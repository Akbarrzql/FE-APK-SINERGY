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

   Future<EditProfileModel> updateProfile(Map<String, dynamic> body, {File? profileImageFile}) async {
     final token = await _sharedCode.getAuthToken();
     final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/update/users/current');

    // NOTE: server currently does not accept multipart/form-data for this endpoint.
    // If caller provided a profileImageFile, we will ignore it for now and send JSON.
    if (profileImageFile != null) {
      if (kDebugMode) debugPrint('PROFILE UPDATE DEBUG: profileImageFile provided but multipart not supported by server; ignoring file=${profileImageFile.path}');
    }

    // No file (or file ignored): send JSON body
    // Filter out empty strings (except explicit profilePicture clearing) to avoid server issues
    final filtered = <String, dynamic>{};
    body.forEach((k, v) {
      if (k == 'profilePicture') {
        // keep explicit empty string to signal removal
        if (v != null) filtered[k] = v;
      } else {
        if (v != null && v.toString().trim().isNotEmpty) filtered[k] = v;
      }
    });

    if (kDebugMode) {
      debugPrint('PROFILE UPDATE DEBUG: sending JSON to $url');
      debugPrint('PROFILE UPDATE DEBUG: headers: ${{
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token'
      }}');
      debugPrint('PROFILE UPDATE DEBUG: body (filtered): ${jsonEncode(filtered)}');
    }

    final response = await http.patch(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(filtered),
    );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Try to parse expected model, but tolerate different response shapes
        try {
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
        } catch (e) {
          // Parsing failed but server returned success status. Create a minimal success model
          String message = 'Berhasil memperbarui profil.';
          try {
            final Map<String, dynamic> jsonBody = jsonDecode(response.body);
            if (jsonBody.containsKey('message')) message = jsonBody['message'].toString();
            else if (jsonBody.containsKey('msg')) message = jsonBody['msg'].toString();
            else if (jsonBody.containsKey('error')) message = jsonBody['error'].toString();
          } catch (_) {}

          // Build minimal Data object using any fields we have in the filtered request
          final minimalData = Data(
            userId: 0,
            email: filtered['email']?.toString() ?? '',
            token: '',
            expiredAt: 0,
            namaLengkap: filtered['namaLengkap']?.toString() ?? '',
            profilePicture: filtered['profilePicture']?.toString() ?? '',
            institusi: filtered['institusi'],
            bio: filtered['bio'],
            keahlian: filtered['keahlian']?.toString() ?? '',
            lokasi: filtered['lokasi'],
            whatsapp: filtered['whatsapp'],
          );

          final fallback = EditProfileModel(status: response.statusCode, message: message, data: minimalData);
          return fallback;
        }
      } else {
       String message = 'Terjadi kesalahan. Silakan coba lagi.';
       try {
         final Map<String, dynamic> json = jsonDecode(response.body);
         if (json.containsKey('details')) {
           message = json['details'].toString();
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

