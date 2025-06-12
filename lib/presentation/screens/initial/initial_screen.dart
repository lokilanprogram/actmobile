import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/api/auth/auth_api.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/domain/deeplinks/deeplinks.dart';
import 'package:acti_mobile/domain/firebase/firebase.dart';
import 'package:acti_mobile/domain/firebase/notification/notification.dart';
import 'package:acti_mobile/presentation/screens/auth/select_input/select_input_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_around/events_around_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../domain/websocket/websocket.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  ProfileModel? profile;
  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    final storage = SecureStorageService();
    try {
      final accessToken = await storage.getAccessToken();
      final refreshToken = await storage.getRefreshToken();
      if (accessToken != null) {
        profile = await ProfileApi().getProfile();
      }

      print('access token ---- $accessToken');
      print('refresh token ---- $refreshToken');
      await Future.delayed(Duration(seconds: 1)).then((_) async {
        if (profile != null) {
          storage.setUserId(profile!.id);
          storage.setUserVerified(profile!.isEmailVerified);
          if (profile!.categories.isNotEmpty) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MapScreen(
                          selectedScreenIndex: 0,
                        )));
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => EventsAroundScreen()));
          }
          await FirebaseApi().initNotifications();
          await NotificationService().initNotification();
          //await NotificationService().checkInitialNotification();
          await FirebaseApi().setupInteractedMessage();
        } else {
          await storage.deleteAll();
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => SelectInputScreen()));
        }
      });
    } catch (e) {
      print(e.toString());
      await storage.deleteAll();
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => SelectInputScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: LoaderWidget());
  }
}
