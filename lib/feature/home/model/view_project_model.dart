import 'dart:convert';

import 'category_parser.dart';

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
    status: json["status"] is int ? json["status"] : int.tryParse(json["status"]?.toString() ?? '0') ?? 0,
    message: json["message"]?.toString() ?? '',
    data: json["data"] != null && json["data"] is List
        ? List<Datum>.from((json["data"] as List).map((x) => Datum.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String title;
  String description;
  List<String> category;
  String? status;
  String? repositoryLink;
  String? projectPicture;
  DateTime? deadline;
  Owner owner;
  List<CollaboratorShort>? collaborators;

  Datum({
    required this.id,
    required this.title,
    required this.description,
    this.category = const [],
    this.status,
    this.repositoryLink,
    this.projectPicture,
    this.deadline,
    required this.owner,
    this.collaborators,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
      title: json["title"]?.toString() ?? '',
      description: json["description"]?.toString() ?? '',
      category: parseCategoryList(json["category"]),
      status: json["status"]?.toString(),
      repositoryLink: json["repositoryLink"]?.toString(),
      projectPicture: json["projectPicture"]?.toString(),
      deadline: json["deadline"] != null ? DateTime.tryParse(json["deadline"].toString()) : null,
      owner: json["owner"] != null && json["owner"] is Map<String, dynamic>
          ? Owner.fromJson(json["owner"])
          : Owner(id: 0, fullName: 'Unknown', email: '', profilePicture: null),
      collaborators: json["collaborators"] != null && json["collaborators"] is List
          ? List<CollaboratorShort>.from((json["collaborators"] as List).map((x) => CollaboratorShort.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "category": category,
    "status": status,
    "repositoryLink": repositoryLink,
    "projectPicture": projectPicture,
    "deadline": deadline?.toIso8601String(),
    "owner": owner.toJson(),
    "collaborators": collaborators == null ? [] : List<dynamic>.from(collaborators!.map((x) => x.toJson())),
  };
}

class CollaboratorShort {
  int id;
  String? profilePicture;

  CollaboratorShort({
    required this.id,
    this.profilePicture,
  });

  factory CollaboratorShort.fromJson(Map<String, dynamic> json) => CollaboratorShort(
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
    profilePicture: json["profilePicture"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "profilePicture": profilePicture,
  };
}

class Owner {
  int id;
  String fullName;
  String email;
  String? profilePicture;

  Owner({
    required this.id,
    required this.fullName,
    required this.email,
    this.profilePicture,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
    fullName: json["fullName"]?.toString() ?? 'Unknown',
    email: json["email"]?.toString() ?? '',
    profilePicture: json["profilePicture"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fullName": fullName,
    "email": email,
    "profilePicture": profilePicture,
  };
}
