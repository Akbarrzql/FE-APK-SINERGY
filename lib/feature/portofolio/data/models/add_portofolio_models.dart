import 'dart:convert';

class AddPortofolioModels {
  int? status;
  String? message;
  Data? data;

  AddPortofolioModels({
    this.status,
    this.message,
    this.data,
  });

  factory AddPortofolioModels.fromRawJson(String str) => AddPortofolioModels.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AddPortofolioModels.fromJson(Map<String, dynamic> json) => AddPortofolioModels(
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
  int? portfolioId;
  int? idPengguna;
  String? title;
  String? description;
  String? fileUrl;
  String? image;
  String? uploadDate;

  Data({
    this.portfolioId,
    this.idPengguna,
    this.title,
    this.description,
    this.fileUrl,
    this.image,
    this.uploadDate,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    portfolioId: json["portfolioId"],
    idPengguna: json["idPengguna"],
    title: json["title"],
    description: json["description"],
    fileUrl: json["fileUrl"],
    image: json["image"],
    uploadDate: json["uploadDate"],
  );

  Map<String, dynamic> toJson() => {
    "portfolioId": portfolioId,
    "idPengguna": idPengguna,
    "title": title,
    "description": description,
    "fileUrl": fileUrl,
    "image": image,
    "uploadDate": uploadDate,
  };
}
