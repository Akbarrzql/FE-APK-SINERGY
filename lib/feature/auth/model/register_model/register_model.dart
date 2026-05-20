import 'dart:convert';

RegisterModel registerModelFromJson(String str) =>
    RegisterModel.fromJson(json.decode(str));

String registerModelToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  int? status;
  String? message;
  String? error;
  String? details;
  Data? data;

  RegisterModel({
    this.status,
    this.message,
    this.error,
    this.details,
    this.data,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
    status: json["status"],
    message: json["message"],
    error: json["error"],
    details: json["details"],
    data: json["data"] != null ? Data.fromJson(json["data"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "error": error,
    "details": details,
    "data": data?.toJson(),
  };
}

class Data {
  int userId;
  String email;
  String token;
  int expiredAt;
  String namaLengkap;
  dynamic profilePicture;
  String? institusi;
  String? bio;
  List<String>? keahlian;
  String? lokasi;
  String? whatsapp;
  String? instagram;
  String? facebook;
  String? linkedin;

  Data({
    required this.userId,
    required this.email,
    required this.token,
    required this.expiredAt,
    required this.namaLengkap,
    required this.profilePicture,
    this.institusi,
    this.bio,
    this.keahlian,
    this.lokasi,
    this.whatsapp,
    this.instagram,
    this.facebook,
    this.linkedin,
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
    keahlian: json["keahlian"] != null
        ? List<String>.from(json["keahlian"].map((x) => x))
        : null,
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
    "keahlian": keahlian != null
        ? List<dynamic>.from(keahlian!.map((x) => x))
        : null,
    "lokasi": lokasi,
    "whatsapp": whatsapp,
    "instagram": instagram,
    "facebook": facebook,
    "linkedin": linkedin,
  };
}
