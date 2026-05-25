// To parse this JSON data, do
//
//     final pendingCollaborationModel = pendingCollaborationModelFromJson(jsonString);

import 'dart:convert';

import 'category_parser.dart';

PendingCollaborationModel pendingCollaborationModelFromJson(String str) => PendingCollaborationModel.fromJson(json.decode(str));

String pendingCollaborationModelToJson(PendingCollaborationModel data) => json.encode(data.toJson());

class PendingCollaborationModel {
  int? status;
  String? message;
  Data? data;

  PendingCollaborationModel({
    this.status,
    this.message,
    this.data,
  });

  factory PendingCollaborationModel.fromJson(Map<String, dynamic> json) => PendingCollaborationModel(
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
  String? status;
  Project? project;
  List<Collaborator>? collaborators;

  Data({
    this.status,
    this.project,
    this.collaborators,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    status: json["status"],
    project: json["project"] == null ? null : Project.fromJson(json["project"]),
    collaborators: json["collaborators"] == null ? [] : List<Collaborator>.from(json["collaborators"]!.map((x) => Collaborator.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "project": project?.toJson(),
    "collaborators": collaborators == null ? [] : List<dynamic>.from(collaborators!.map((x) => x.toJson())),
  };
}

class Collaborator {
  int? collaborationId;
  int? idPengguna;
  String? namaLengkap;
  String? email;
  dynamic profilePicture;
  String? institusi;
  String? bio;
  String? keahlian;
  String? lokasi;
  dynamic whatsapp;
  dynamic instagram;
  dynamic facebook;
  dynamic linkedin;
  String? role;
  String? status;
  String? requestStatus;
  DateTime? requestedAt;

  Collaborator({
    this.collaborationId,
    this.idPengguna,
    this.namaLengkap,
    this.email,
    this.profilePicture,
    this.institusi,
    this.bio,
    this.keahlian,
    this.lokasi,
    this.whatsapp,
    this.instagram,
    this.facebook,
    this.linkedin,
    this.role,
    this.status,
    this.requestStatus,
    this.requestedAt,
  });

  factory Collaborator.fromJson(Map<String, dynamic> json) => Collaborator(
    collaborationId: json["collaborationId"],
    idPengguna: json["idPengguna"],
    namaLengkap: json["namaLengkap"],
    email: json["email"],
    profilePicture: json["profilePicture"],
    institusi: json["institusi"],
    bio: json["bio"],
    keahlian: json["keahlian"],
    lokasi: json["lokasi"],
    whatsapp: json["whatsapp"],
    instagram: json["instagram"],
    facebook: json["facebook"],
    linkedin: json["linkedin"],
    role: json["role"],
    status: json["status"],
    requestStatus: json["requestStatus"],
    requestedAt: json["requestedAt"] == null ? null : DateTime.parse(json["requestedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "collaborationId": collaborationId,
    "idPengguna": idPengguna,
    "namaLengkap": namaLengkap,
    "email": email,
    "profilePicture": profilePicture,
    "institusi": institusi,
    "bio": bio,
    "keahlian": keahlian,
    "lokasi": lokasi,
    "whatsapp": whatsapp,
    "instagram": instagram,
    "facebook": facebook,
    "linkedin": linkedin,
    "role": role,
    "status": status,
    "requestStatus": requestStatus,
    "requestedAt": requestedAt?.toIso8601String(),
  };
}

class Project {
  int? projectId;
  String? title;
  String? description;
  List<String> category;
  String? status;
  String? repositoryLink;
  String? projectPicture;

  Project({
    this.projectId,
    this.title,
    this.description,
    this.category = const [],
    this.status,
    this.repositoryLink,
    this.projectPicture,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    projectId: json["projectId"],
    title: json["title"],
    description: json["description"],
    category: parseCategoryList(json["category"]),
    status: json["status"],
    repositoryLink: json["repositoryLink"],
    projectPicture: json["projectPicture"],
  );

  Map<String, dynamic> toJson() => {
    "projectId": projectId,
    "title": title,
    "description": description,
    "category": category,
    "status": status,
    "repositoryLink": repositoryLink,
    "projectPicture": projectPicture,
  };
}
