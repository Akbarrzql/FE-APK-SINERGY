import 'dart:convert';

List<PortofolioModel> portofolioModelFromJson(String str) {
  final jsonData = json.decode(str);

  // Jika respons Apidog dibungkus di dalam objek { "data": [...] }
  if (jsonData is Map && jsonData.containsKey('data')) {
    return List<PortofolioModel>.from(
      jsonData['data'].map((x) => PortofolioModel.fromJson(x)),
    );
  }

  // Jika respons Apidog langsung berupa Array List [...]
  return List<PortofolioModel>.from(
    jsonData.map((x) => PortofolioModel.fromJson(x)),
  );
}

String portofolioModelToJson(PortofolioModel data) => json.encode(data.toJson());

class PortofolioModel {
  final String id;
  final String title;
  final String description;
  final String fileUrl;
  final String image;

  PortofolioModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.image,
  });

  factory PortofolioModel.fromJson(Map<String, dynamic> json) => PortofolioModel(
    id: json["id"]?.toString() ?? "",
    title: json["title"] ?? json["judul"] ?? "",
    description: json["description"] ?? json["deskripsi"] ?? "",
    fileUrl: json["fileUrl"] ?? "",
    image: json["image"] ?? "https://via.placeholder.com/150",
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "fileUrl": fileUrl,
    "image": image,
  };
}