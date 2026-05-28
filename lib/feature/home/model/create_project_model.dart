// To parse this JSON data, do
//
//     final createProjectModel = createProjectModelFromJson(jsonString);

import 'dart:convert';

import 'category_parser.dart';

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
  List<String> category;
  String status;
  String repositoryLink;
  String projectPicture;
  DateTime? deadline;

  Data({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.repositoryLink,
    required this.projectPicture,
    this.deadline,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    category: parseCategoryList(json["category"]),
    status: json["status"],
    repositoryLink: json["repositoryLink"],
    projectPicture: json["projectPicture"],
    deadline: json["deadline"] != null ? DateTime.tryParse(json["deadline"].toString()) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "category": category,
    "status": status,
    "repositoryLink": repositoryLink,
    "projectPicture": projectPicture,
    "deadline": deadline?.toIso8601String(),
  };
}
