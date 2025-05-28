import 'dart:convert';
import 'dart:io';
import 'package:acti_mobile/domain/firebase/notification/notification.dart';
import 'package:acti_mobile/main.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseApi {
  final firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission();
    if(Platform.isIOS){
    await Future.delayed(Duration(seconds: 1));
    final apnsToken =  await firebaseMessaging.getAPNSToken();
   print('Firebase apns token ${apnsToken}');

  }
   final token = await firebaseMessaging.getToken();
   print('Firebase token ${token}');
  
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

  void _handleMessage(RemoteMessage message) {
  final decoded = message.data;
  if (decoded['event_id'] != null) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => MapScreen(selectedScreenIndex: 0,),
      ),
    ).then((_){
      navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(eventId: decoded['event_id'],),
      ),
    );
    });
  }
}
}
