// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  int idPengguna;
  String profilePicture;
  String namaLengkap;
  String email;
  dynamic institusi;
  dynamic bio;
  dynamic keahlian;
  dynamic lokasi;
  dynamic whatsapp;

  ProfileModel({
    required this.idPengguna,
    required this.profilePicture,
    required this.namaLengkap,
    required this.email,
    required this.institusi,
    required this.bio,
    required this.keahlian,
    required this.lokasi,
    required this.whatsapp,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    idPengguna: json["idPengguna"],
    profilePicture: json["profilePicture"]?.toString() ?? '',
    namaLengkap: json["namaLengkap"],
    email: json["email"],
    institusi: json["institusi"],
    bio: json["bio"],
    keahlian: json["keahlian"],
    lokasi: json["lokasi"],
    whatsapp: json["whatsapp"],
  );

  Map<String, dynamic> toJson() => {
    "idPengguna": idPengguna,
    "profilePicture": profilePicture,
    "namaLengkap": namaLengkap,
    "email": email,
    "institusi": institusi,
    "bio": bio,
    "keahlian": keahlian,
    "lokasi": lokasi,
    "whatsapp": whatsapp,
  };
}
