import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/api/auth/auth_api.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/domain/deeplinks/deeplinks.dart';
import 'package:acti_mobile/domain/firebase/firebase.dart';
import 'package:acti_mobile/domain/firebase/notification/notification.dart';
import 'package:acti_mobile/presentation/screens/auth/select_input/select_input_screen.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/onboardings_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

import '../../../domain/websocket/websocket.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  ProfileModel? profile;

  Future<void> _checkLocationPermission() async {
    developer.log('Проверка разрешений геолокации', name: 'INITIAL_SCREEN');

    bool serviceEnabled;
    LocationPermission permission;

    // Проверяем, включена ли служба геолокации
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      developer.log('Служба геолокации отключена', name: 'INITIAL_SCREEN');
      return;
    }

    // Проверяем разрешения
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      developer.log('Запрашиваем разрешение на геолокацию',
          name: 'INITIAL_SCREEN');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        developer.log('Разрешение на геолокацию отклонено',
            name: 'INITIAL_SCREEN');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      developer.log('Разрешение на геолокацию отклонено навсегда',
          name: 'INITIAL_SCREEN');
      return;
    }

    developer.log('Разрешение на геолокацию получено', name: 'INITIAL_SCREEN');
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    final storage = SecureStorageService();
    try {
      // Запрашиваем разрешение на геолокацию
      await _checkLocationPermission();

      final accessToken = await storage.getAccessToken();
      final refreshToken = await storage.getRefreshToken();
      if (accessToken != null) {
        profile = await ProfileApi().getProfile();
      }

      print('access token ---- $accessToken');
      print('refresh token ---- $refreshToken');

      if (!mounted) return;

      await Future.delayed(Duration(seconds: 1));

      if (!mounted) return;

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
    } catch (e) {
      print(e.toString());
      if (!mounted) return;

      await storage.deleteAll();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SelectInputScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: LoaderWidget());
  }
}
