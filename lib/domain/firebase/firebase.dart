import 'dart:convert';
import 'dart:io';
import 'package:acti_mobile/domain/api/auth/auth_api.dart';
import 'package:acti_mobile/domain/api/chat/chat_api.dart';
import 'package:acti_mobile/domain/firebase/notification/notification.dart';
import 'package:acti_mobile/main.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/chat_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/screen/public_user_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/detail/event_detail_home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FirebaseApi {
  final firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications() async {
    String? token;
    NotificationSettings settings = await firebaseMessaging.requestPermission();
    if (Platform.isIOS) {
      token = await firebaseMessaging.getAPNSToken();
      print('Firebase apns token ${token}');
      await Future.delayed(Duration(seconds: 2));
    } else {
      token = await firebaseMessaging.getToken();
      print('Firebase token  ${token}');
    }

    if (token != null) {
      try {
        await AuthApi().sendFcmToken(token);
      } catch (e) {
        print(e.toString());
      }
    }
    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await NotificationService().showListingsNotification(
          message.notification!.title!,
          message.notification!.body!,
          jsonEncode(message.data));
    });
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final decoded = message.data;
    String? eventId = decoded['event_id'];
    String? chatId = decoded["chat_id"];
    String? userId = decoded["user_id"];
    String? isOrganizer = decoded["is_organizer"];

    final navigator = navigatorKey.currentState;

    if (navigator == null) return;

    if (chatId != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            interlocutorChatId: chatId,
          ),
        ),
      );
    } else if (eventId != null) {
      if (isOrganizer == "true") {
        try {
          navigator.push(
            MaterialPageRoute(
              builder: (_) => EventDetailHomeScreen(
                eventId: eventId,
              ),
            ),
          );
        } on Exception catch (e) {
          print("");
        }
      } else {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(
              eventId: eventId,
            ),
          ),
        );
      }
    } else if (userId != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => PublicUserScreen(
            userId: userId,
          ),
        ),
      );
    } else {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => MainScreen(),
        ),
      );
    }
  }
}
