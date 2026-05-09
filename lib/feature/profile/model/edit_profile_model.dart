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
    status: json["status"] ?? 0,
    message: json["message"] ?? '',
    data: Data.fromJson(json["data"] ?? {}),
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
    userId: json["userId"] ?? 0,
    email: json["email"] ?? '',
    token: json["token"] ?? '',
    expiredAt: json["expiredAt"] ?? 0,
    namaLengkap: json["namaLengkap"] ?? '',
    profilePicture: json["profilePicture"]?.toString() ?? '',
    institusi: json["institusi"]?.toString() ?? '',
    bio: json["bio"]?.toString() ?? '',
    keahlian: json["keahlian"] == null 
        ? [] 
        : List<String>.from(json["keahlian"].map((x) => x.toString())),
    lokasi: json["lokasi"]?.toString() ?? '',
    whatsapp: json["whatsapp"]?.toString() ?? '',
    instagram: json["instagram"]?.toString() ?? '',
    facebook: json["facebook"]?.toString() ?? '',
    linkedin: json["linkedin"]?.toString() ?? '',
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
