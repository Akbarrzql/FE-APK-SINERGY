import 'dart:convert';

class DeletePortofolioModel {
  int? status;
  String? message;
  dynamic data;

  DeletePortofolioModel({
    this.status,
    this.message,
    this.data,
  });

  factory DeletePortofolioModel.fromRawJson(String str) => DeletePortofolioModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DeletePortofolioModel.fromJson(Map<String, dynamic> json) => DeletePortofolioModel(
    status: json["status"],
    message: json["message"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data,
  };
}
