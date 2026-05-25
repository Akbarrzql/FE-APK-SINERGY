import 'dart:convert';

ViewProfileModel viewProfileModelFromJson(String str) => ViewProfileModel.fromJson(json.decode(str));

String viewProfileModelToJson(ViewProfileModel data) => json.encode(data.toJson());

class ViewProfileModel {
  int idPengguna;
  String profilePicture;
  String namaLengkap;
  String email;
  String institusi;
  String bio;
  List<String> keahlian;
  String lokasi;
  String whatsapp;
  String instagram;
  String facebook;
  String linkedin;

  ViewProfileModel({
    required this.idPengguna,
    required this.profilePicture,
    required this.namaLengkap,
    required this.email,
    required this.institusi,
    required this.bio,
    required this.keahlian,
    required this.lokasi,
    required this.whatsapp,
    required this.instagram,
    required this.facebook,
    required this.linkedin,
  });

  factory ViewProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] != null ? json["data"] : json;
    return ViewProfileModel(
      idPengguna: data["idPengguna"] is int
          ? data["idPengguna"]
          : int.tryParse(data["idPengguna"]?.toString() ?? data["id"]?.toString() ?? '0') ?? 0,
      profilePicture: data["profilePicture"]?.toString() ?? '',
      namaLengkap: data["namaLengkap"] ?? '',
      email: data["email"] ?? '',
      institusi: data["institusi"]?.toString() ?? '',
      bio: data["bio"]?.toString() ?? '',
      keahlian: data["keahlian"] == null 
          ? [] 
          : List<String>.from(data["keahlian"].map((x) => x.toString())),
      lokasi: data["lokasi"]?.toString() ?? '',
      whatsapp: data["whatsapp"]?.toString() ?? '',
      instagram: data["instagram"]?.toString() ?? '',
      facebook: data["facebook"]?.toString() ?? '',
      linkedin: data["linkedin"]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "idPengguna": idPengguna,
    "profilePicture": profilePicture,
    "namaLengkap": namaLengkap,
    "email": email,
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
