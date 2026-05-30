import 'package:equatable/equatable.dart';
import 'package:gabungyuk/feature/notification/model/notification_model.dart';
import 'package:gabungyuk/feature/notification/model/unread_notification_model.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationData> notifications;
  final UnreadNotificationData? unreadData;
  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.unreadData,
    this.errorMessage,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationData>? notifications,
    UnreadNotificationData? unreadData,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadData: unreadData ?? this.unreadData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, unreadData, errorMessage];
}
