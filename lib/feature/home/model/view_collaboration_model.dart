import 'dart:convert';

import 'category_parser.dart';

ViewCollaborationModel viewCollaborationModelFromJson(String str) => ViewCollaborationModel.fromJson(json.decode(str));

String viewCollaborationModelToJson(ViewCollaborationModel data) => json.encode(data.toJson());

class ViewCollaborationModel {
  int? status;
  String? message;
  Data? data;

  ViewCollaborationModel({
    this.status,
    this.message,
    this.data,
  });

  factory ViewCollaborationModel.fromJson(Map<String, dynamic> json) => ViewCollaborationModel(
    status: json["status"] is int ? json["status"] : int.tryParse(json["status"]?.toString() ?? ''),
    message: json["message"]?.toString(),
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  int? collaborationId;
  int? idPengguna;
  Owner? owner;
  Project? project;
  int? projectId;
  String? role;
  String? status;

  Data({
    this.collaborationId,
    this.idPengguna,
    this.owner,
    this.project,
    this.projectId,
    this.role,
    this.status,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    collaborationId: json["collaborationId"] is int ? json["collaborationId"] : int.tryParse(json["collaborationId"]?.toString() ?? ''),
    idPengguna: json["idPengguna"] is int ? json["idPengguna"] : int.tryParse(json["idPengguna"]?.toString() ?? ''),
    owner: json["owner"] == null ? null : Owner.fromJson(json["owner"]),
    project: json["project"] == null ? null : Project.fromJson(json["project"]),
    projectId: json["projectId"] is int ? json["projectId"] : int.tryParse(json["projectId"]?.toString() ?? ''),
    role: json["role"]?.toString(),
    status: json["status"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "collaborationId": collaborationId,
    "idPengguna": idPengguna,
    "owner": owner?.toJson(),
    "project": project?.toJson(),
    "projectId": projectId,
    "role": role,
    "status": status,
  };
}

class Owner {
  String? email;
  int? idPengguna;
  String? namaLengkap;
  String? profilePicture;

  Owner({
    this.email,
    this.idPengguna,
    this.namaLengkap,
    this.profilePicture,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    email: json["email"]?.toString(),
    idPengguna: json["idPengguna"] is int ? json["idPengguna"] : int.tryParse(json["idPengguna"]?.toString() ?? ''),
    namaLengkap: json["namaLengkap"]?.toString(),
    profilePicture: json["profilePicture"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "idPengguna": idPengguna,
    "namaLengkap": namaLengkap,
    "profilePicture": profilePicture,
  };
}

class Project {
  List<String> category;
  String? description;
  int? projectId;
  String? projectPicture;
  String? repositoryLink;
  String? status;
  String? title;

  Project({
    this.category = const [],
    this.description,
    this.projectId,
    this.projectPicture,
    this.repositoryLink,
    this.status,
    this.title,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    category: parseCategoryList(json["category"]),
    description: json["description"]?.toString(),
    projectId: json["projectId"] is int ? json["projectId"] : int.tryParse(json["projectId"]?.toString() ?? ''),
    projectPicture: json["projectPicture"]?.toString(),
    repositoryLink: json["repositoryLink"]?.toString(),
    status: json["status"]?.toString(),
    title: json["title"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "category": category,
    "description": description,
    "projectId": projectId,
    "projectPicture": projectPicture,
    "repositoryLink": repositoryLink,
    "status": status,
    "title": title,
  };
}
