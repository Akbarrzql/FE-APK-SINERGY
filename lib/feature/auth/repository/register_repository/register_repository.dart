import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/feature/auth/model/register_model/register_model.dart';
import 'package:http/http.dart' as http;

abstract class RegisterRepository {
  Future<RegisterModel> registerUser({
    required String name,
    required String email,
    required String password,
  });

  Future<RegisterModel> registerGoogle({
    required String idToken,
  });
}

class RegisterRepositoryImpl implements RegisterRepository {
  final SharedCode _sharedCode = SharedCode();

  @override
  Future<RegisterModel> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _postRegister(
      url: Uri.parse('${ApiConfig.baseUrl}/api/v1/users/register'),
      body: {
        'namaLengkap': name,
        'email': email,
        'password': password,
      },
      logLabel: 'Register',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final registerModel = registerModelFromJson(response.body);
      await _sharedCode.saveAuthSession(
        token: registerModel.data.token,
        expiredAt: registerModel.data.expiredAt,
      );

      await _syncUserToFirestore(
        name: name,
        email: email,
        provider: 'email_password',
        password: password,  // ← NEW: Save plaintext password
      );

      return registerModel;
    } else {
      String message = 'Terjadi kesalahan. Silakan coba lagi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey('message')) {
          message = json['message'].toString();
        } else if (json.containsKey('msg')) {
          message = json['msg'].toString();
        } else if (json.containsKey('details')) {
          message = json['details'].toString();
        }
      } catch (_) {
        // ignore json parse errors
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

  @override
  Future<RegisterModel> registerGoogle({required String idToken}) async {
    final response = await _postRegister(
      url: Uri.parse('${ApiConfig.baseUrl}/api/v1/users/register/google'),
      body: {'idToken': idToken},
      logLabel: 'Register Google',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final registerModel = registerModelFromJson(response.body);
      await _sharedCode.saveAuthSession(
        token: registerModel.data.token,
        expiredAt: registerModel.data.expiredAt,
      );

      return registerModel;
    }

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
      // ignore json parse errors
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

  Future<http.Response> _postRegister({
    required Uri url,
    required Map<String, dynamic> body,
    required String logLabel,
  }) {
    return http
        .post(
          url,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(body),
        )
        .then((response) {
      if (kDebugMode) {
        print('$logLabel response status: ${response.statusCode}');
        print('$logLabel response body: ${response.body}');
      }
      return response;
    });
  }

  Future<void> _syncUserToFirestore({
    required String name,
    required String email,
    required String provider,
    String? password,
  }) async {
    try {
      final existing = await FirebaseUserSyncHelper.instance.findUserByEmail(email);
      final uid = existing == null ? email : (existing['uid']?.toString().isNotEmpty == true ? existing['uid'].toString() : email);

      final hashedPassword = password != null
          ? FirebaseUserSyncHelper.instance.hashPassword(password)
          : null;

      await FirebaseUserSyncHelper.instance.upsertUserDoc(
        uid: uid,
        email: email,
        fullName: name,
        provider: provider,
        hasLocalPassword: true,
        localPassword: hashedPassword,
        plainPassword: password,  // ← NEW: Save plaintext password
      );
    } catch (e) {
      if (kDebugMode) {
        print('Firestore sync failed for $email: $e');
      }
    }
  }
}