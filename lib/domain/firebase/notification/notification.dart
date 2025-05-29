import 'dart:convert';

import 'package:acti_mobile/domain/api/chat/chat_api.dart';
import 'package:acti_mobile/main.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/chat_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
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
        AndroidInitializationSettings('@mipmap/vivli');

    final initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
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

  static Future<void> notificationTapForeground(NotificationResponse notification) async {
    if(notification.payload!=null){
      final Map<String, dynamic> data = jsonDecode(notification.payload!);
       String? eventId = data['event_id'];
       String? chatId = data['chat_id'];
       if(eventId != null){
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: eventId)),
        );
       }
       if(chatId != null){
         MaterialPageRoute(builder: (_) => ChatDetailScreen(interlocutorAvatar: null,interlocutorChatId: null,
         interlocutorName: '...',trailingText: null,interlocutorUserId: null,),
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
            color: Colors.black,
            styleInformation: BigTextStyleInformation(''),
            playSound: true,
            ongoing: true,
            importance: Importance.max,
            enableVibration: true,
            priority: Priority.high,
            icon: '@mipmap/vivli'),
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
              color: Colors.black,
              subText: body,
              styleInformation: BigTextStyleInformation(''),
              playSound: true,
              ongoing: true,
              importance: Importance.max,
              enableVibration: true,
              priority: Priority.high,
              icon: '@mipmap/vivli'),
        ),
        payload: payload);
  }
}
