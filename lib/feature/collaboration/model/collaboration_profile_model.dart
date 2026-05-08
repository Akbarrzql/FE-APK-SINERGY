// To parse this JSON data, do
//
//     final collaborationProfileModel = collaborationProfileModelFromJson(jsonString);

import 'dart:convert';

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
  String? category;
  String? status;
  String? repositoryLink;
  String? projectPicture;

  OwnedProject({
    this.id,
    this.title,
    this.description,
    this.category,
    this.status,
    this.repositoryLink,
    this.projectPicture,
  });

  factory OwnedProject.fromJson(Map<String, dynamic> json) => OwnedProject(
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
