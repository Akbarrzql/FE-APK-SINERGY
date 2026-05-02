import 'dart:convert';
import 'dart:io';
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/feature/auth/model/login_model/login_model.dart';
import 'package:http/http.dart' as http;

abstract class LoginRepository {
  Future<LoginModel> loginUser({
    required String email,
    required String password,
  });
}

class LoginRepositoryImpl implements LoginRepository {
  final SharedCode _sharedCode = SharedCode();

  @override
  Future<LoginModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/login');
    final response = await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final loginModel = loginModelFromJson(response.body);
      await _sharedCode.saveAuthSession(
        token: loginModel.data.token,
        expiredAt: loginModel.data.expiredAt,
      );
      return loginModel;
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

      // fallback messages based on status code
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



