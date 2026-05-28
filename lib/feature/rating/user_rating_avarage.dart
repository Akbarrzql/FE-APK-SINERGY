import 'dart:convert';

class UserRatingAvarage {
  int? status;
  String? message;
  Data? data;

  UserRatingAvarage({
    this.status,
    this.message,
    this.data,
  });

  factory UserRatingAvarage.fromRawJson(String str) => UserRatingAvarage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserRatingAvarage.fromJson(Map<String, dynamic> json) => UserRatingAvarage(
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
  String? namaLengkap;
  dynamic profilePicture;
  int? averageRating;
  int? totalRatings;

  Data({
    this.userId,
    this.namaLengkap,
    this.profilePicture,
    this.averageRating,
    this.totalRatings,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["userId"],
    namaLengkap: json["namaLengkap"],
    profilePicture: json["profilePicture"],
    averageRating: json["averageRating"],
    totalRatings: json["totalRatings"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "namaLengkap": namaLengkap,
    "profilePicture": profilePicture,
    "averageRating": averageRating,
    "totalRatings": totalRatings,
  };
}
