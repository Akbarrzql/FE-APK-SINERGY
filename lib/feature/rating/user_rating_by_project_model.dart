import 'dart:convert';

class UserRatingByProjectModel {
  int? status;
  String? message;
  Data? data;

  UserRatingByProjectModel({
    this.status,
    this.message,
    this.data,
  });

  factory UserRatingByProjectModel.fromRawJson(String str) => UserRatingByProjectModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserRatingByProjectModel.fromJson(Map<String, dynamic> json) => UserRatingByProjectModel(
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
  List<Rating>? ratings;

  Data({
    this.userId,
    this.namaLengkap,
    this.profilePicture,
    this.averageRating,
    this.totalRatings,
    this.ratings,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["userId"],
    namaLengkap: json["namaLengkap"],
    profilePicture: json["profilePicture"],
    averageRating: json["averageRating"],
    totalRatings: json["totalRatings"],
    ratings: json["ratings"] == null ? [] : List<Rating>.from(json["ratings"]!.map((x) => Rating.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "namaLengkap": namaLengkap,
    "profilePicture": profilePicture,
    "averageRating": averageRating,
    "totalRatings": totalRatings,
    "ratings": ratings == null ? [] : List<dynamic>.from(ratings!.map((x) => x.toJson())),
  };
}

class Rating {
  int? ratingId;
  int? projectId;
  String? projectTitle;
  int? ratedUserId;
  String? ratedUserName;
  dynamic ratedUserProfilePicture;
  int? ownerUserId;
  String? ownerName;
  dynamic ownerProfilePicture;
  int? ratingValue;
  String? review;
  DateTime? createdAt;
  dynamic updatedAt;

  Rating({
    this.ratingId,
    this.projectId,
    this.projectTitle,
    this.ratedUserId,
    this.ratedUserName,
    this.ratedUserProfilePicture,
    this.ownerUserId,
    this.ownerName,
    this.ownerProfilePicture,
    this.ratingValue,
    this.review,
    this.createdAt,
    this.updatedAt,
  });

  factory Rating.fromRawJson(String str) => Rating.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    ratingId: json["ratingId"],
    projectId: json["projectId"],
    projectTitle: json["projectTitle"],
    ratedUserId: json["ratedUserId"],
    ratedUserName: json["ratedUserName"],
    ratedUserProfilePicture: json["ratedUserProfilePicture"],
    ownerUserId: json["ownerUserId"],
    ownerName: json["ownerName"],
    ownerProfilePicture: json["ownerProfilePicture"],
    ratingValue: json["ratingValue"],
    review: json["review"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "ratingId": ratingId,
    "projectId": projectId,
    "projectTitle": projectTitle,
    "ratedUserId": ratedUserId,
    "ratedUserName": ratedUserName,
    "ratedUserProfilePicture": ratedUserProfilePicture,
    "ownerUserId": ownerUserId,
    "ownerName": ownerName,
    "ownerProfilePicture": ownerProfilePicture,
    "ratingValue": ratingValue,
    "review": review,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt,
  };
}
