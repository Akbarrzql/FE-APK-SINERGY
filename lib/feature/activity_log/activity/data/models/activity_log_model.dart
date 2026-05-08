// To parse this JSON data, do
//
//     final activityLogModel = activityLogModelFromJson(jsonString);

import 'dart:convert';

ActivityLogModel activityLogModelFromJson(String str) => ActivityLogModel.fromJson(json.decode(str));

String activityLogModelToJson(ActivityLogModel data) => json.encode(data.toJson());

class ActivityLogModel {
  int? status;
  String? message;
  List<Datum>? data;

  ActivityLogModel({
    this.status,
    this.message,
    this.data,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) => ActivityLogModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? activityLogId;
  String? namaLengkap;
  int? projectId;
  String? message;
  bool? isRead;
  String? timestamp;

  Datum({
    this.activityLogId,
    this.namaLengkap,
    this.projectId,
    this.message,
    this.isRead,
    this.timestamp,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    activityLogId: json["activityLogId"],
    namaLengkap: json["namaLengkap"],
    projectId: json["projectId"],
    message: json["message"],
    isRead: json["isRead"],
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "activityLogId": activityLogId,
    "namaLengkap": namaLengkap,
    "projectId": projectId,
    "message": message,
    "isRead": isRead,
    "timestamp": timestamp,
  };
}
