import 'dart:convert';
import 'dart:io';
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/feature/task/data/models/recap_model.dart';
import 'package:http/http.dart' as http;

abstract class RecapRepository {
  Future<RecapModel> fetchRecap(String filterWaktu);
}

class RecapRepositoryImpl implements RecapRepository {
  final SharedCode _sharedCode = SharedCode();

  @override
  Future<RecapModel> fetchRecap(String filterWaktu) async {
    // DUMMY DATA - hapus setelah API siap
    await Future.delayed(const Duration(seconds: 1));
    return RecapModel(
      totalKontribusi: 24,
      totalProyek: 6,
      chartData: filterWaktu == 'mingguan'
          ? [
              ChartData(label: 'Sen', value: 3),
              ChartData(label: 'Sel', value: 5),
              ChartData(label: 'Rab', value: 2),
              ChartData(label: 'Kam', value: 8),
              ChartData(label: 'Jum', value: 4),
            ]
          : [
              ChartData(label: 'Jan', value: 10),
              ChartData(label: 'Feb', value: 15),
              ChartData(label: 'Mar', value: 8),
              ChartData(label: 'Apr', value: 20),
            ],
    );

    // UNCOMMENT INI SETELAH API SIAP:
    // final token = await _sharedCode.getAuthToken();
    // final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/recap?filter=$filterWaktu');
    // final response = await http.get(url, headers: {
    //   HttpHeaders.contentTypeHeader: 'application/json',
    //   HttpHeaders.authorizationHeader: 'Bearer $token',
    // });
    // if (response.statusCode >= 200 && response.statusCode < 300) {
    //   return recapModelFromJson(response.body);
    // } else {
    //   String message = 'Terjadi kesalahan. Silakan coba lagi.';
    //   try {
    //     final Map<String, dynamic> json = jsonDecode(response.body);
    //     message = json['message'] ?? json['msg'] ?? json['details'] ?? message;
    //   } catch (_) {}
    //   throw ApiException(message, response.statusCode);
    // }
  }
}
