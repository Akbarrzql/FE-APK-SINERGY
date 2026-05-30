import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/feature/notification/bloc/notification_event.dart';
import 'package:gabungyuk/feature/notification/bloc/notification_state.dart';
import 'package:gabungyuk/feature/notification/service/notification_service.dart';

import '../model/unread_notification_model.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;

  NotificationBloc(this._notificationService) : super(const NotificationState()) {
    on<FetchNotifications>((event, emit) async {
      emit(state.copyWith(status: NotificationStatus.loading));
      try {
        final notifications = await _notificationService.getAllNotifications();
        emit(state.copyWith(
          status: NotificationStatus.loaded,
          notifications: notifications,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ));
      }
    });

    on<FetchUnreadCount>((event, emit) async {
      try {
        final unreadData = await _notificationService.getUnreadNotifications();
        emit(state.copyWith(unreadData: unreadData));
      } catch (e) {
        // Silently fail for unread count
      }
    });

    on<MarkNotificationAsRead>((event, emit) async {
      if (state.status == NotificationStatus.loaded) {
        // Optimistic update for the list
        final updatedNotifications = state.notifications.map((n) {
          if (n.notificationId == event.notificationId) {
            return n.copyWith(isRead: true, readAt: DateTime.now());
          }
          return n;
        }).toList();
        
        // Optimistic update for the badge count
        UnreadNotificationData? updatedUnreadData;
        if (state.unreadData != null && state.unreadData!.unreadCount > 0) {
            updatedUnreadData = state.unreadData!.copyWith(
              unreadCount: state.unreadData!.unreadCount - 1
            );
        }

        emit(state.copyWith(
          notifications: updatedNotifications,
          unreadData: updatedUnreadData,
        ));

        try {
          await _notificationService.markAsRead(event.notificationId);
          // Sync with server unread count
          add(FetchUnreadCount());
        } catch (e) {
          // Revert or fetch again if failed
          add(FetchNotifications());
        }
      }
    });

    on<MarkAllNotificationsAsRead>((event, emit) async {
      if (state.status == NotificationStatus.loaded) {
        // Optimistic update
        final updatedNotifications = state.notifications.map((n) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }).toList();

        emit(state.copyWith(
          notifications: updatedNotifications,
          unreadData: state.unreadData?.copyWith(unreadCount: 0),
        ));

        try {
          await _notificationService.markAllAsRead();
          add(FetchUnreadCount());
        } catch (e) {
          add(FetchNotifications());
        }
      }
    });
  }
}
