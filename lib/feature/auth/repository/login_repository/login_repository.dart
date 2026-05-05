import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/feature/auth/model/login_model/login_model.dart';
import 'package:http/http.dart' as http;

abstract class LoginRepository {
  Future<LoginModel> loginUser({
    required String email,
    required String password,
  });

  Future<LoginModel> loginGoogle({
    required String idToken,
  });
}

class LoginRepositoryImpl implements LoginRepository {
  final SharedCode _sharedCode = SharedCode();

  @override
  Future<LoginModel> loginUser({
    required String email,
    required String password,
  }) async {
    return _loginWithBackend(
      email: email,
      password: password,
      allowGoogleFallback: true,
    );
  }

  @override
  Future<LoginModel> loginGoogle({required String idToken}) async {
    return _postLogin(
      url: Uri.parse('${ApiConfig.baseUrl}/api/v1/users/login/google'),
      body: {'idToken': idToken},
      logLabel: 'Login Google',
    );
  }

  Future<LoginModel> _loginWithBackend({
    required String email,
    required String password,
    required bool allowGoogleFallback,
  }) async {
    return _postLogin(
      url: Uri.parse('${ApiConfig.baseUrl}/api/v1/users/login'),
      body: {
        'email': email,
        'password': password,
      },
      logLabel: 'Login',
      allowGoogleFallback: allowGoogleFallback,
      email: email,
      password: password,
    );
  }

  Future<LoginModel> _postLogin({
    required Uri url,
    required Map<String, dynamic> body,
    required String logLabel,
    bool allowGoogleFallback = false,
    String? email,
    String? password,
  }) async {
    final response = await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );

    if (kDebugMode) {
      print('$logLabel response status: ${response.statusCode}');
      print('$logLabel response body: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final loginModel = loginModelFromJson(response.body);
        await _sharedCode.saveAuthSession(
          token: loginModel.data.token,
          expiredAt: loginModel.data.expiredAt,
        );
        return loginModel;
      } catch (parseError) {
        if (kDebugMode) print('Login model parsing error: $parseError, response: ${response.body}');
        throw ApiException(
          AuthUiHelper.toIndonesianMessage(
            'Format respons tidak valid dari server. Silakan coba lagi.',
          ),
          response.statusCode,
        );
      }
    }

    String message = 'Terjadi kesalahan. Silakan coba lagi.';
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json.containsKey('message')) {
        message = AuthUiHelper.toIndonesianMessage(json['message'].toString());
      } else if (json.containsKey('msg')) {
        message = AuthUiHelper.toIndonesianMessage(json['msg'].toString());
      } else if (json.containsKey('details')) {
        message = AuthUiHelper.toIndonesianMessage(json['details'].toString());
      }
    } catch (_) {
      // ignore json parse errors
    }

    if (allowGoogleFallback &&
        email != null &&
        password != null &&
        _shouldTryGoogleFallback(response.statusCode, message)) {
      final googleSecret = await _resolveGoogleSecret(email);
      if (googleSecret != null && googleSecret.isNotEmpty && googleSecret != password) {
        if (kDebugMode) {
          print('Login fallback: retrying Google-linked account for $email');
        }
        return _loginWithBackend(
          email: email,
          password: googleSecret,
          allowGoogleFallback: false,
        );
      }
    }

    if (response.statusCode == 400) {
      if (message.isEmpty) message = 'Permintaan tidak valid. Periksa kembali input.';
    } else if (response.statusCode == 401) {
      if (message.isEmpty) message = 'Email atau password salah. Silakan coba lagi.';
    } else if (response.statusCode >= 500) {
      if (message.isEmpty) message = 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
    }

    throw ApiException(AuthUiHelper.toIndonesianMessage(message), response.statusCode);
  }

  bool _shouldTryGoogleFallback(int statusCode, String message) {
    if (statusCode == 401 || statusCode == 400) return true;
    final lower = message.toLowerCase();
    return lower.contains('password') || lower.contains('credential') || lower.contains('invalid');
  }

  Future<String?> _resolveGoogleSecret(String email) async {
    try {
      final userData = await FirebaseUserSyncHelper.instance.findUserByEmail(email);
      if (userData == null) return null;

      final provider = userData['provider']?.toString() ?? '';
      final googleUid = userData['google_uid']?.toString() ?? '';
      final hasLocalPassword = userData['has_local_password'] as bool? ?? false;

      // 🔑 Priority:
      // 1. Jika sudah ada local password, gunakan googleSecret (untuk fallback ke Google login)
      // 2. Jika pure Google provider, gunakan derived secret
      if (hasLocalPassword && googleUid.isNotEmpty) {
        // User sudah set password lokal pada Google account
        // Return googleSecret sebagai fallback untuk Google re-login
        return FirebaseUserSyncHelper.instance.deriveGoogleSecret(googleUid);
      }

      if (provider == 'google' && googleUid.isNotEmpty) {
        return FirebaseUserSyncHelper.instance.deriveGoogleSecret(googleUid);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Login fallback error: $e');
      }
      return null;
    }
  }
}
