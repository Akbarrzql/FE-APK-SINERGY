import 'dart:convert';
import 'dart:io';
import 'package:gabungyuk/core/common/api_config.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/feature/rating/model/create_rating_model.dart';
import 'package:gabungyuk/feature/rating/model/user_rating_by_project_model.dart';
import 'package:gabungyuk/feature/rating/model/user_rating_average_model.dart';
import 'package:gabungyuk/feature/rating/user_rating_in_project.dart';
import 'package:http/http.dart' as http;

abstract class RatingRepository {
  Future<void> submitRating(CreateRatingCollaboratorsModel rating);
  Future<UserRatingInProject> getRatingsByProject(int projectId);
  Future<UserRatingByProjectModel> getRatingsByUser(int userId);
  Future<UserRatingAverageModel> getAverageRating(int userId);
}

class RatingRepositoryImpl implements RatingRepository {
  final SharedCode _sharedCode = SharedCode();

  @override
  Future<void> submitRating(CreateRatingCollaboratorsModel rating) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/ratings');

    final response = await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(rating.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      String message = 'Gagal menyimpan rating. Silakan coba lagi.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['details'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  @override
  Future<UserRatingInProject> getRatingsByProject(int projectId) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/ratings/projects/$projectId');

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return UserRatingInProject.fromRawJson(response.body);
    } else {
      String message = 'Gagal memuat rating project.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['details'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  @override
  Future<UserRatingByProjectModel> getRatingsByUser(int userId) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/ratings/users/$userId');

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return UserRatingByProjectModel.fromRawJson(response.body);
    } else {
      String message = 'Gagal memuat rating user.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['details'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  @override
  Future<UserRatingAverageModel> getAverageRating(int userId) async {
    final token = await _sharedCode.getAuthToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/ratings/users/$userId/average');

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return UserRatingAverageModel.fromRawJson(response.body);
    } else {
      String message = 'Gagal memuat average rating user.';
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        message = json['message'] ?? json['details'] ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }
}

