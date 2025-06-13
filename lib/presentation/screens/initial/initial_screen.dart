import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/api/auth/auth_api.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/domain/deeplinks/deeplinks.dart';
import 'package:acti_mobile/domain/firebase/firebase.dart';
import 'package:acti_mobile/domain/firebase/notification/notification.dart';
import 'package:acti_mobile/presentation/screens/auth/select_input/select_input_screen.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen_provider.dart';
import 'package:acti_mobile/presentation/screens/onbording/onboardings_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';

import '../../../domain/websocket/websocket.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  ProfileModel? profile;

  initialize() async {
    final storage = SecureStorageService();
    try {
      final accessToken = await storage.getAccessToken();
      final refreshToken = await storage.getRefreshToken();
      if (accessToken != null) {
        await connectToOnlineStatus(accessToken).catchError((e) {
          developer.log('Ошибка при подключении к WebSocket: $e',
              name: 'MAP_SCREEN');
        });
        profile = await ProfileApi().getProfile();
      }

      await Future.delayed(Duration(seconds: 1)).then((_) async {
        if (profile != null) {
          storage.setUserId(profile!.id);
          storage.setUserVerified(profile!.isEmailVerified);
          if (profile!.categories.isNotEmpty) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingsScreen()),
            );
          }
          await FirebaseApi().initNotifications();
          await NotificationService().initNotification();
          await FirebaseApi().setupInteractedMessage();
        } else {
          await storage.deleteAll();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SelectInputScreen()),
          );
        }
      });
    } catch (e) {
      print(e.toString());
      await storage.deleteAll();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SelectInputScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<MainScreenProvider>(
        builder: (context, provider, child) {
          return const Center(
            child: LoaderWidget(),
          );
        },
      ),
    );
  }
}
