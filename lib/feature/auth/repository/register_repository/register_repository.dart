import 'dart:io';

import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'dart:convert';
import 'package:gabungyuk/feature/auth/model/register_model/register_model.dart';
import 'package:http/http.dart' as http;

abstract class RegisterRepository {
  Future<RegisterModel> registerUser({
    required String name,
    required String email,
    required String password,
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
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/register');
    final response = await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: '{"username": "$name", "email": "$email", "password": "$password"}',
    );

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      final registerModel = registerModelFromJson(response.body);
      await _sharedCode.saveAuthSession(
        token: registerModel.data.token,
        expiredAt: registerModel.data.expiredAt,
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
  }
}