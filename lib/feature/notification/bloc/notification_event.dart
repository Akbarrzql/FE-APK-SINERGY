import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotificationEvent {}

class FetchUnreadCount extends NotificationEvent {}

class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;

  MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {}
