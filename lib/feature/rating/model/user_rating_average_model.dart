import 'dart:convert';

class UserRatingAverageModel {
  int? status;
  String? message;
  Data? data;

  UserRatingAverageModel({
    this.status,
    this.message,
    this.data,
  });

  factory UserRatingAverageModel.fromRawJson(String str) =>
      UserRatingAverageModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserRatingAverageModel.fromJson(Map<String, dynamic> json) =>
      UserRatingAverageModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  int? userId;
  double? averageRating;
  int? totalReviews;

  Data({
    this.userId,
    this.averageRating,
    this.totalReviews,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["userId"],
        averageRating: json["averageRating"] is int
            ? (json["averageRating"] as int).toDouble()
            : json["averageRating"],
        totalReviews: json["totalReviews"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "averageRating": averageRating,
        "totalReviews": totalReviews,
      };
}

