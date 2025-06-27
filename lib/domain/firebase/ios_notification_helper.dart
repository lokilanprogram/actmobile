import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class IosNotificationHelper {
  static Future<void> checkNotificationPermissions() async {
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      print('iOS Notification Settings:');
      print('Authorization Status: ${settings.authorizationStatus}');
      print('Alert Setting: ${settings.alert}');
      print('Badge Setting: ${settings.badge}');
      print('Sound Setting: ${settings.sound}');
      print('Critical Alert Setting: ${settings.criticalAlert}');
      
      // Проверяем токены
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      
      print('FCM Token: $fcmToken');
      print('APNS Token: $apnsToken');
    }
  }
  
  static Future<void> requestPermissionsExplicitly() async {
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      print('Permission request result: ${settings.authorizationStatus}');
    }
  }
  
  static Future<void> setupLocalNotificationChannels() async {
    if (Platform.isIOS) {
      final plugin = FlutterLocalNotificationsPlugin();
      
      // iOS не использует каналы, но мы можем настроить базовые параметры
      const iOSSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        iOS: iOSSettings,
      );
      
      await plugin.initialize(initSettings);
      print('iOS Local notification channels configured');
    }
  }
} 