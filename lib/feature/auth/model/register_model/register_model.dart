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
  String username;
  String email;
  String token;
  int expiredAt;

  Data({
    required this.userId,
    required this.username,
    required this.email,
    required this.token,
    required this.expiredAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["userId"],
    username: json["username"],
    email: json["email"],
    token: json["token"],
    expiredAt: json["expiredAt"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "username": username,
    "email": email,
    "token": token,
    "expiredAt": expiredAt,
  };
}
