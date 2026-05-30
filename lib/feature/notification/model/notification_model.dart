import 'dart:convert';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

MarkAsReadModel markAsReadModelFromJson(String str) =>
    MarkAsReadModel.fromJson(json.decode(str));

class NotificationModel {
  final int status;
  final String message;
  final List<NotificationData> data;

  NotificationModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        status: json["status"],
        message: json["message"],
        data: List<NotificationData>.from(
            json["data"].map((x) => NotificationData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class NotificationData {
  final int notificationId;
  final int? recipientUserId;
  final int? actorUserId;
  final int? projectId;
  final int? collaborationId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationData({
    required this.notificationId,
    this.recipientUserId,
    this.actorUserId,
    this.projectId,
    this.collaborationId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        notificationId: json["notificationId"],
        recipientUserId: json["recipientUserId"],
        actorUserId: json["actorUserId"],
        projectId: json["projectId"],
        collaborationId: json["collaborationId"],
        type: json["type"],
        title: json["title"],
        message: json["message"],
        isRead: json["isRead"],
        createdAt: DateTime.parse(json["createdAt"]),
        readAt: json["readAt"] == null ? null : DateTime.parse(json["readAt"]),
      );

  Map<String, dynamic> toJson() => {
        "notificationId": notificationId,
        "recipientUserId": recipientUserId,
        "actorUserId": actorUserId,
        "projectId": projectId,
        "collaborationId": collaborationId,
        "type": type,
        "title": title,
        "message": message,
        "isRead": isRead,
        "createdAt": createdAt.toIso8601String(),
        "readAt": readAt?.toIso8601String(),
      };

  NotificationData copyWith({
    bool? isRead,
    DateTime? readAt,
  }) =>
      NotificationData(
        notificationId: notificationId,
        recipientUserId: recipientUserId,
        actorUserId: actorUserId,
        projectId: projectId,
        collaborationId: collaborationId,
        type: type,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        readAt: readAt ?? this.readAt,
      );
}

class MarkAsReadModel {
  final int status;
  final String message;
  final MarkAsReadData data;

  MarkAsReadModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MarkAsReadModel.fromJson(Map<String, dynamic> json) => MarkAsReadModel(
        status: json["status"],
        message: json["message"],
        data: MarkAsReadData.fromJson(json["data"]),
      );
}

class MarkAsReadData {
  final int notificationId;
  final bool isRead;
  final DateTime? readAt;

  MarkAsReadData({
    required this.notificationId,
    required this.isRead,
    this.readAt,
  });

  factory MarkAsReadData.fromJson(Map<String, dynamic> json) => MarkAsReadData(
        notificationId: json["notificationId"],
        isRead: json["isRead"],
        readAt: json["readAt"] == null ? null : DateTime.parse(json["readAt"]),
      );
}
