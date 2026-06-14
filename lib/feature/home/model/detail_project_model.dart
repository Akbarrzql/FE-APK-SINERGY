import 'dart:convert';

import 'category_parser.dart';

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
    status: json["status"] is int ? json["status"] : int.tryParse(json["status"]?.toString() ?? '0') ?? 0,
    message: json["message"]?.toString() ?? '',
    data: Data.fromJson(json["data"] ?? {}),
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
    status: json["status"]?.toString() ?? '',
    project: Project.fromJson(json["project"] ?? {}),
    collaborators: json["collaborators"] != null && json["collaborators"] is List
        ? List<Collaborator>.from((json["collaborators"] as List).map((x) => Collaborator.fromJson(x)))
        : [],
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
  String? profilePicture;
  String institusi;
  String bio;
  String keahlian;
  String lokasi;
  String? whatsapp;
  String? instagram;
  String? facebook;
  String? linkedin;
  String role;
  String status;
  String requestStatus;
  DateTime? requestedAt;

  Collaborator({
    required this.collaborationId,
    required this.idPengguna,
    required this.namaLengkap,
    required this.email,
    this.profilePicture,
    required this.institusi,
    required this.bio,
    required this.keahlian,
    required this.lokasi,
    this.whatsapp,
    this.instagram,
    this.facebook,
    this.linkedin,
    required this.role,
    required this.status,
    required this.requestStatus,
    this.requestedAt,
  });

  factory Collaborator.fromJson(Map<String, dynamic> json) => Collaborator(
    collaborationId: json["collaborationId"] is int ? json["collaborationId"] : int.tryParse(json["collaborationId"]?.toString() ?? '0') ?? 0,
    idPengguna: json["idPengguna"] is int ? json["idPengguna"] : int.tryParse(json["idPengguna"]?.toString() ?? '0') ?? 0,
    namaLengkap: json["namaLengkap"]?.toString() ?? '',
    email: json["email"]?.toString() ?? '',
    profilePicture: json["profilePicture"]?.toString(),
    institusi: json["institusi"]?.toString() ?? '',
    bio: json["bio"]?.toString() ?? '',
    keahlian: json["keahlian"]?.toString() ?? '',
    lokasi: json["lokasi"]?.toString() ?? '',
    whatsapp: json["whatsapp"]?.toString(),
    instagram: json["instagram"]?.toString(),
    facebook: json["facebook"]?.toString(),
    linkedin: json["linkedin"]?.toString(),
    role: json["role"]?.toString() ?? '',
    status: json["status"]?.toString() ?? '',
    requestStatus: json["requestStatus"]?.toString() ?? '',
    requestedAt: json["requestedAt"] != null ? DateTime.tryParse(json["requestedAt"].toString()) : null,
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
  int projectId;
  String title;
  String description;
  List<String> category;
  String status;
  String repositoryLink;
  String projectPicture;
  DateTime? deadline;

  Project({
    required this.projectId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.repositoryLink,
    required this.projectPicture,
    this.deadline,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    projectId: json["projectId"] is int ? json["projectId"] : int.tryParse(json["projectId"]?.toString() ?? '0') ?? 0,
    title: json["title"]?.toString() ?? '',
    description: json["description"]?.toString() ?? '',
    category: parseCategoryList(json["category"]),
    status: json["status"]?.toString() ?? '',
    repositoryLink: json["repositoryLink"]?.toString() ?? '',
    projectPicture: json["projectPicture"]?.toString() ?? '',
    deadline: json["deadline"] != null ? DateTime.tryParse(json["deadline"].toString()) : null,
  );

  Map<String, dynamic> toJson() => {
    "projectId": projectId,
    "title": title,
    "description": description,
    "category": category,
    "status": status,
    "repositoryLink": repositoryLink,
    "projectPicture": projectPicture,
    "deadline": deadline?.toIso8601String(),
  };
}
