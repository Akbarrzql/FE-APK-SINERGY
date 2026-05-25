import 'dart:convert';

class SearchModel {
  int? status;
  String? message;
  Data? data;

  SearchModel({
    this.status,
    this.message,
    this.data,
  });

  factory SearchModel.fromRawJson(String str) => SearchModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
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
  List<User>? users;
  List<Project>? projects;

  Data({
    this.users,
    this.projects,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    users: json["users"] == null ? [] : List<User>.from(json["users"]!.map((x) => User.fromJson(x))),
    projects: json["projects"] == null ? [] : List<Project>.from(json["projects"]!.map((x) => Project.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "users": users == null ? [] : List<dynamic>.from(users!.map((x) => x.toJson())),
    "projects": projects == null ? [] : List<dynamic>.from(projects!.map((x) => x.toJson())),
  };
}

class Project {
  int? id;
  String? title;
  String? description;
  List<String>? category;
  String? status;
  String? repositoryLink;
  String? projectPicture;
  dynamic deadline;

  Project({
    this.id,
    this.title,
    this.description,
    this.category,
    this.status,
    this.repositoryLink,
    this.projectPicture,
    this.deadline,
  });

  factory Project.fromRawJson(String str) => Project.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    category: json["category"] == null ? [] : List<String>.from(json["category"]!.map((x) => x.toString())),
    status: json["status"],
    repositoryLink: json["repositoryLink"],
    projectPicture: json["projectPicture"],
    deadline: json["deadline"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "category": category == null ? [] : List<dynamic>.from(category!.map((x) => x)),
    "status": status,
    "repositoryLink": repositoryLink,
    "projectPicture": projectPicture,
    "deadline": deadline,
  };
}

class User {
  int? id;
  int? userId;
  int? idPengguna;
  String? namaLengkap;
  dynamic profilePicture;
  String? bio;
  String? institusi;

  User({
    this.id,
    this.userId,
    this.idPengguna,
    this.namaLengkap,
    this.profilePicture,
    this.bio,
    this.institusi,
  });

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ''),
    userId: json["userId"] is int ? json["userId"] : int.tryParse(json["userId"]?.toString() ?? ''),
    idPengguna: json["idPengguna"] is int ? json["idPengguna"] : int.tryParse(json["idPengguna"]?.toString() ?? ''),
    namaLengkap: json["namaLengkap"]?.toString(),
    profilePicture: json["profilePicture"],
    bio: json["bio"]?.toString(),
    institusi: json["institusi"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "idPengguna": idPengguna,
    "namaLengkap": namaLengkap,
    "profilePicture": profilePicture,
    "bio": bio,
    "institusi": institusi,
  };
}
