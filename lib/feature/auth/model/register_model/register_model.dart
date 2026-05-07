// To parse this JSON data, do
//
//     final registerModel = registerModelFromJson(jsonString);

import 'dart:convert';

RegisterModel registerModelFromJson(String str) => RegisterModel.fromJson(json.decode(str));

String registerModelToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  int status;
  String message;
  Data data;

  RegisterModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
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
  int userId;
  String email;
  String token;
  int expiredAt;
  String namaLengkap;
  dynamic profilePicture;
  String institusi;
  String bio;
  List<String> keahlian;
  String lokasi;
  String whatsapp;
  String instagram;
  String facebook;
  String linkedin;

  Data({
    required this.userId,
    required this.email,
    required this.token,
    required this.expiredAt,
    required this.namaLengkap,
    required this.profilePicture,
    required this.institusi,
    required this.bio,
    required this.keahlian,
    required this.lokasi,
    required this.whatsapp,
    required this.instagram,
    required this.facebook,
    required this.linkedin,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["userId"],
    email: json["email"],
    token: json["token"],
    expiredAt: json["expiredAt"],
    namaLengkap: json["namaLengkap"],
    profilePicture: json["profilePicture"],
    institusi: json["institusi"],
    bio: json["bio"],
    keahlian: List<String>.from(json["keahlian"].map((x) => x)),
    lokasi: json["lokasi"],
    whatsapp: json["whatsapp"],
    instagram: json["instagram"],
    facebook: json["facebook"],
    linkedin: json["linkedin"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "email": email,
    "token": token,
    "expiredAt": expiredAt,
    "namaLengkap": namaLengkap,
    "profilePicture": profilePicture,
    "institusi": institusi,
    "bio": bio,
    "keahlian": List<dynamic>.from(keahlian.map((x) => x)),
    "lokasi": lokasi,
    "whatsapp": whatsapp,
    "instagram": instagram,
    "facebook": facebook,
    "linkedin": linkedin,
  };
}
