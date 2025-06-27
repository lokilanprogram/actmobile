import 'dart:convert';

import 'package:acti_mobile/domain/api/chat/chat_api.dart';
import 'package:acti_mobile/main.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/chat_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/screen/public_user_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/detail/event_detail_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initNotification() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/icon_acti');

    final initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
        onDidReceiveNotificationResponse: notificationTapForeground);
  }

  static void notificationTapBackground(NotificationResponse notification) {
    print('background for messaging');
  }

  static Future<void> notificationTapForeground(
      NotificationResponse notification) async {
    if (notification.payload != null) {
      final Map<String, dynamic> data = jsonDecode(notification.payload!);
      String? eventId = data['event_id'];
      String? chatId = data['chat_id'];
      String? userId = data["user_id"];
      String? isOrganizer = data["is_organizer"];

      final navigator = navigatorKey.currentState;

      if (navigator == null) return;

      if (chatId != null) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              interlocutorChatId: chatId,
            ),
          ),
          (route) => false,
        );
        navigator.push(
          MaterialPageRoute(
            builder: (_) => MainScreen(initialIndex: 0),
          ),
        );
      } else if (eventId != null) {
        if (isOrganizer == "true") {
          try {
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => EventDetailHomeScreen(
                  eventId: eventId,
                ),
              ),
              (route) => false,
            );
            navigator.push(
              MaterialPageRoute(
                builder: (_) => MainScreen(initialIndex: 0),
              ),
            );
          } on Exception catch (e) {
            print("");
          }
        } else {
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(
                eventId: eventId,
              ),
            ),
            (route) => false,
          );
          navigator.push(
            MaterialPageRoute(
              builder: (_) => MainScreen(initialIndex: 0),
            ),
          );
        }
      } else if (userId != null) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => PublicUserScreen(
              userId: userId,
            ),
          ),
          (route) => false,
        );
        navigator.push(
          MaterialPageRoute(
            builder: (_) => MainScreen(initialIndex: 0),
          ),
        );
      } else {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MainScreen(initialIndex: 0),
          ),
          (route) => false,
        );
      }
    }
  }

  Future<void> showMessageNotification(String title, String body) async {
    await flutterLocalNotificationsPlugin.show(
      2,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails('channel_two', 'Channel Two',
            channelShowBadge: true,
            styleInformation: BigTextStyleInformation(''),
            playSound: true,
            color: Colors.white,
            ongoing: true,
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/icon_acti'),
            importance: Importance.max,
            enableVibration: true,
            priority: Priority.high,
            icon: '@mipmap/icon_acti'),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          badgeNumber: 1,
          threadIdentifier: 'message_notification',
        ),
      ),
    );
  }

  Future<void> showListingsNotification(
      String title, String body, String payload) async {
    await flutterLocalNotificationsPlugin.show(
        1,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails('channel_two', 'Channel Two',
              channelShowBadge: true,
              subText: body,
              largeIcon: DrawableResourceAndroidBitmap('@mipmap/icon_acti'),
              color: Colors.white,
              styleInformation: BigTextStyleInformation(''),
              playSound: true,
              ongoing: true,
              importance: Importance.max,
              enableVibration: true,
              priority: Priority.high,
              icon: '@mipmap/icon_acti'),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            badgeNumber: 1,
            threadIdentifier: 'listings_notification',
          ),
        ),
        payload: payload);
  }
}
