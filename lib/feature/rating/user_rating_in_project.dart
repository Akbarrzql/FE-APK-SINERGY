import 'dart:convert';

class UserRatingInProject {
  int? status;
  String? message;
  List<Datum>? data;

  UserRatingInProject({
    this.status,
    this.message,
    this.data,
  });

  factory UserRatingInProject.fromRawJson(String str) => UserRatingInProject.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserRatingInProject.fromJson(Map<String, dynamic> json) => UserRatingInProject(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
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

  Datum({
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

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
