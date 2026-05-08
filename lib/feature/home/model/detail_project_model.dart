// To parse this JSON data, do
//
//     final detailProjectModel = detailProjectModelFromJson(jsonString);

import 'dart:convert';

DetailProjectModel detailProjectModelFromJson(String str) => DetailProjectModel.fromJson(json.decode(str));

String detailProjectModelToJson(DetailProjectModel data) => json.encode(data.toJson());

class DetailProjectModel {
  int status;
  String message;
  Data data;

  DetailProjectModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DetailProjectModel.fromJson(Map<String, dynamic> json) => DetailProjectModel(
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
  String status;
  Project project;
  List<Collaborator> collaborators;

  Data({
    required this.status,
    required this.project,
    required this.collaborators,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    status: json["status"],
    project: Project.fromJson(json["project"]),
    collaborators: List<Collaborator>.from(json["collaborators"].map((x) => Collaborator.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "project": project.toJson(),
    "collaborators": List<dynamic>.from(collaborators.map((x) => x.toJson())),
  };
}

class Collaborator {
  int collaborationId;
  int idPengguna;
  String namaLengkap;
  String email;
  dynamic profilePicture;
  String institusi;
  String bio;
  String keahlian;
  String lokasi;
  dynamic whatsapp;
  dynamic instagram;
  dynamic facebook;
  dynamic linkedin;
  String role;
  String status;
  String requestStatus;
  DateTime requestedAt;

  Collaborator({
    required this.collaborationId,
    required this.idPengguna,
    required this.namaLengkap,
    required this.email,
    required this.profilePicture,
    required this.institusi,
    required this.bio,
    required this.keahlian,
    required this.lokasi,
    required this.whatsapp,
    required this.instagram,
    required this.facebook,
    required this.linkedin,
    required this.role,
    required this.status,
    required this.requestStatus,
    required this.requestedAt,
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
    requestedAt: DateTime.parse(json["requestedAt"]),
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
    "requestedAt": requestedAt.toIso8601String(),
  };
}

class Project {
  int projectId;
  String title;
  String description;
  String category;
  String status;
  String repositoryLink;
  String projectPicture;

  Project({
    required this.projectId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.repositoryLink,
    required this.projectPicture,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    projectId: json["projectId"],
    title: json["title"] ?? '',
    description: json["description"] ?? '',
    category: json["category"] ?? '',
    status: json["status"] ?? '',
    repositoryLink: json["repositoryLink"] ?? '',
    projectPicture: json["projectPicture"] ?? '',
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
