import 'dart:convert';

class CreateRatingCollaboratorsModel {
  int? status;
  String? message;
  Data? data;

  CreateRatingCollaboratorsModel({
    this.status,
    this.message,
    this.data,
  });

  factory CreateRatingCollaboratorsModel.fromRawJson(String str) => CreateRatingCollaboratorsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreateRatingCollaboratorsModel.fromJson(Map<String, dynamic> json) => CreateRatingCollaboratorsModel(
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

  Data({
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

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
