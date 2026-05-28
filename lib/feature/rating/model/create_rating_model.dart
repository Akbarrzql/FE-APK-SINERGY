import 'dart:convert';

class CreateRatingCollaboratorsModel {
  int projectId;
  int ratedUserId;
  int ratingValue;
  String review;

  CreateRatingCollaboratorsModel({
    required this.projectId,
    required this.ratedUserId,
    required this.ratingValue,
    required this.review,
  });

  factory CreateRatingCollaboratorsModel.fromRawJson(String str) =>
      CreateRatingCollaboratorsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreateRatingCollaboratorsModel.fromJson(Map<String, dynamic> json) =>
      CreateRatingCollaboratorsModel(
        projectId: json["projectId"] ?? 0,
        ratedUserId: json["ratedUserId"] ?? 0,
        ratingValue: json["ratingValue"] ?? 0,
        review: json["review"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "projectId": projectId,
        "ratedUserId": ratedUserId,
        "ratingValue": ratingValue,
        "review": review,
      };
}

