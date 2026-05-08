// To parse this JSON data, do
//
//     final createProjectModel = createProjectModelFromJson(jsonString);

import 'dart:convert';

CreateProjectModel createProjectModelFromJson(String str) => CreateProjectModel.fromJson(json.decode(str));

String createProjectModelToJson(CreateProjectModel data) => json.encode(data.toJson());

class CreateProjectModel {
  int status;
  String message;
  Data data;

  CreateProjectModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CreateProjectModel.fromJson(Map<String, dynamic> json) => CreateProjectModel(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  int id;
  String title;
  String description;
  String category;
  String status;
  String repositoryLink;
  String projectPicture;

  Data({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.repositoryLink,
    required this.projectPicture,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    category: json["category"],
    status: json["status"],
    repositoryLink: json["repositoryLink"],
    projectPicture: json["projectPicture"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "category": category,
    "status": status,
    "repositoryLink": repositoryLink,
    "projectPicture": projectPicture,
  };
}
