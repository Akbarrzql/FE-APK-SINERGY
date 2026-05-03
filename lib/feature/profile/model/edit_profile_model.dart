// To parse this JSON data, do
//
//     final editProfileModel = editProfileModelFromJson(jsonString);

import 'dart:convert';

EditProfileModel editProfileModelFromJson(String str) => EditProfileModel.fromJson(json.decode(str));

String editProfileModelToJson(EditProfileModel data) => json.encode(data.toJson());

class EditProfileModel {
  int status;
  String message;
  Data data;

  EditProfileModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EditProfileModel.fromJson(Map<String, dynamic> json) => EditProfileModel(
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
  String profilePicture;
  dynamic institusi;
  dynamic bio;
  String keahlian;
  dynamic lokasi;
  dynamic whatsapp;

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
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["userId"],
    email: json["email"],
    token: json["token"],
    expiredAt: json["expiredAt"],
    namaLengkap: json["namaLengkap"],
    profilePicture: json["profilePicture"]?.toString() ?? '',
    institusi: json["institusi"],
    bio: json["bio"],
    keahlian: json["keahlian"],
    lokasi: json["lokasi"],
    whatsapp: json["whatsapp"],
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
    "keahlian": keahlian,
    "lokasi": lokasi,
    "whatsapp": whatsapp,
  };
}
