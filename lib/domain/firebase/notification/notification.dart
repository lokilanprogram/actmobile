import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  static void notificationTapForeground(NotificationResponse notification) {
    // if (notification.id == 1) {
    //   Map<String, dynamic> decoded = jsonDecode(notification.payload!);
    //   sectionANavigatorKey.currentState!.push(MaterialPageRoute(
    //       builder: (context) => AdvertsHomeFilterPage(
    //           advertsHomeCategoryModel: AdvertsHomeCategoryModel(
    //               isTriple: false,
    //               categoryFetchedModel: CategoryFetchedModel(
    //                   id: int.parse(decoded['id']),
    //                   name: decoded['localized_name']),
    //               subCategoryFetchedModel: null,
    //               lat: null,
    //               lon: null,
    //               priceMax: null,
    //               priceMin: null))));
    // }
    print('foreground for messaging and listings');
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
