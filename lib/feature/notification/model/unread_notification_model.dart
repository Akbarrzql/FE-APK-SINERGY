import 'dart:convert';

UnreadNotificationModel unreadNotificationModelFromJson(String str) => UnreadNotificationModel.fromJson(json.decode(str));

class UnreadNotificationModel {
  final int status;
  final String message;
  final UnreadNotificationData data;

  UnreadNotificationModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UnreadNotificationModel.fromJson(Map<String, dynamic> json) => UnreadNotificationModel(
    status: json["status"],
    message: json["message"],
    data: UnreadNotificationData.fromJson(json["data"]),
  );
}

class UnreadNotificationData {
  final int unreadCount;
  final List<UnreadNotificationItem> notifications;

  UnreadNotificationData({
    required this.unreadCount,
    required this.notifications,
  });

  factory UnreadNotificationData.fromJson(Map<String, dynamic> json) => UnreadNotificationData(
    unreadCount: json["unreadCount"],
    notifications: List<UnreadNotificationItem>.from(json["notifications"].map((x) => UnreadNotificationItem.fromJson(x))),
  );

  UnreadNotificationData copyWith({
    int? unreadCount,
    List<UnreadNotificationItem>? notifications,
  }) =>
      UnreadNotificationData(
        unreadCount: unreadCount ?? this.unreadCount,
        notifications: notifications ?? this.notifications,
      );
}

class UnreadNotificationItem {
  final int notificationId;
  final String title;
  final bool isRead;

  UnreadNotificationItem({
    required this.notificationId,
    required this.title,
    required this.isRead,
  });

  factory UnreadNotificationItem.fromJson(Map<String, dynamic> json) => UnreadNotificationItem(
    notificationId: json["notificationId"],
    title: json["title"],
    isRead: json["isRead"],
  );
}
