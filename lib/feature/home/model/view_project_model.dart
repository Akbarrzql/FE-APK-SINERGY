// To parse this JSON data, do
//
//     final viewProjectModel = viewProjectModelFromJson(jsonString);

import 'dart:convert';

ViewProjectModel viewProjectModelFromJson(String str) => ViewProjectModel.fromJson(json.decode(str));

String viewProjectModelToJson(ViewProjectModel data) => json.encode(data.toJson());

class ViewProjectModel {
  int status;
  String message;
  List<Datum> data;

  ViewProjectModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ViewProjectModel.fromJson(Map<String, dynamic> json) => ViewProjectModel(
    status: json["status"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  int? idPengguna;
  String title;
  String description;
  String? category;
  String? status;
  String? repositoryLink;
  String? projectPicture;

  Datum({
    required this.id,
    this.idPengguna,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.repositoryLink,
    required this.projectPicture,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    idPengguna: json["idPengguna"],
    title: json["title"],
    description: json["description"],
    category: json["category"],
    status: json["status"],
    repositoryLink: json["repositoryLink"],
    projectPicture: json["projectPicture"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "idPengguna": idPengguna,
    "title": title,
    "description": description,
    "category": category,
    "status": status,
    "repositoryLink": repositoryLink,
    "projectPicture": projectPicture,
  };
}
