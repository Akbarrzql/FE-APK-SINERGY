import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gabungyuk/core/common/firebase_user_sync_helper.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _setupForegroundPresentation();

    _listenToForegroundMessages();
    _listenToTokenRefresh();

    await fetchAndSyncFcmToken();
  }

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('Notification permission: ${settings.authorizationStatus}');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) {
          print('Notification clicked: ${details.payload}');
        }
      },
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Channel untuk notifikasi penting',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _setupForegroundPresentation() async {
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _listenToTokenRefresh() {
    _fcm.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print('FCM token refreshed: $newToken');
      }

      await _syncTokenToFirestore(newToken);
    });
  }

  Future<String?> getFcmToken() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _waitForApnsToken();

        if (apnsToken == null) {
          if (kDebugMode) {
            print('APNS token belum tersedia. FCM token belum bisa diambil.');
          }
          return null;
        }

        if (kDebugMode) {
          print('APNS token: $apnsToken');
        }
      }

      final token = await _fcm.getToken();

      if (kDebugMode) {
        print('FCM token: $token');
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Gagal mengambil FCM token: $e');
      }
      return null;
    }
  }

  Future<String?> _waitForApnsToken() async {
    for (int i = 0; i < 1; i++) {
      final apnsToken = await _fcm.getAPNSToken();

      if (apnsToken != null) {
        return apnsToken;
      }

      if (kDebugMode) {
        print('Menunggu APNS token... attempt ${i + 1}');
      }

      await Future.delayed(const Duration(seconds: 2));
    }

    return null;
  }

  Future<void> fetchAndSyncFcmToken() async {
    final token = await getFcmToken();

    if (token != null) {
      await _syncTokenToFirestore(token);
    }
  }

  Future<void> syncTokenAfterLogin(String email) async {
    final token = await getFcmToken();

    if (token != null) {
      if (kDebugMode) {
        print('Sync FCM token untuk $email: $token');
      }

      await FirebaseUserSyncHelper.instance.updateFcmToken(email, token);
    }
  }

  Future<void> _syncTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      if (kDebugMode) {
        print('User belum login, FCM token belum disimpan.');
      }
      return;
    }

    await FirebaseUserSyncHelper.instance.updateFcmToken(
      user.email!,
      token,
    );

    if (kDebugMode) {
      print('FCM token berhasil disimpan ke Firestore.');
    }
  }

  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message: ${message.messageId}');
      }

      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Channel untuk notifikasi penting',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
      payload: message.data.toString(),
    );
  }
}