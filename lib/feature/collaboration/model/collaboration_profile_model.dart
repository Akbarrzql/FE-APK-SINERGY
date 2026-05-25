// To parse this JSON data, do
//
//     final collaborationProfileModel = collaborationProfileModelFromJson(jsonString);

import 'dart:convert';

import '../../home/model/category_parser.dart';
import '../../home/model/view_project_model.dart';

CollaborationProfileModel collaborationProfileModelFromJson(String str) => CollaborationProfileModel.fromJson(json.decode(str));

String collaborationProfileModelToJson(CollaborationProfileModel data) => json.encode(data.toJson());

class CollaborationProfileModel {
  int? status;
  String? message;
  Data? data;

  CollaborationProfileModel({
    this.status,
    this.message,
    this.data,
  });

  factory CollaborationProfileModel.fromJson(Map<String, dynamic> json) => CollaborationProfileModel(
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
  List<OwnedProject>? ownedProjects;
  List<dynamic>? requestCollab;

  Data({
    this.ownedProjects,
    this.requestCollab,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    ownedProjects: json["ownedProjects"] == null ? [] : List<OwnedProject>.from(json["ownedProjects"]!.map((x) => OwnedProject.fromJson(x))),
    requestCollab: json["requestCollab"] == null ? [] : List<dynamic>.from(json["requestCollab"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "ownedProjects": ownedProjects == null ? [] : List<dynamic>.from(ownedProjects!.map((x) => x.toJson())),
    "requestCollab": requestCollab == null ? [] : List<dynamic>.from(requestCollab!.map((x) => x)),
  };
}

class OwnedProject {
  int? id;
  String? title;
  String? description;
  List<String> category;
  String? status;
  String? repositoryLink;
  String? projectPicture;
  List<CollaboratorShort>? collaborators;

  OwnedProject({
    this.id,
    this.title,
    this.description,
    this.category = const [],
    this.status,
    this.repositoryLink,
    this.projectPicture,
    this.collaborators,
  });

  factory OwnedProject.fromJson(Map<String, dynamic> json) => OwnedProject(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    category: parseCategoryList(json["category"]),
    status: json["status"],
    repositoryLink: json["repositoryLink"],
    projectPicture: json["projectPicture"],
    collaborators: json["collaborators"] == null ? [] : List<CollaboratorShort>.from(json["collaborators"]!.map((x) => CollaboratorShort.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "category": category,
    "status": status,
    "repositoryLink": repositoryLink,
    "projectPicture": projectPicture,
    "collaborators": collaborators == null ? [] : List<dynamic>.from(collaborators!.map((x) => x.toJson())),
  };
}
