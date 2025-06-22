import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/api/auth/auth_api.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/domain/deeplinks/deeplinks.dart';
import 'package:acti_mobile/domain/firebase/firebase.dart';
import 'package:acti_mobile/domain/firebase/notification/notification.dart';
import 'package:acti_mobile/domain/services/map_optimization_service.dart';
import 'package:acti_mobile/presentation/screens/auth/select_input/select_input_screen.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen_provider.dart';
import 'package:acti_mobile/presentation/screens/onbording/onboardings_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/websocket/websocket.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  ProfileModel? profile;
  final MapOptimizationService _mapOptimizationService =
      MapOptimizationService();

  Future<void> _requestLocationPermission() async {
    developer.log('Запрос разрешения геолокации', name: 'INITIAL_SCREEN');

    // Проверяем, включена ли служба геолокации
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;

      // Показываем диалог с просьбой включить геолокацию
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Геолокация отключена'),
            content: const Text(
                'Для работы приложения необходимо включить геолокацию в настройках устройства.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Проверяем текущие разрешения
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Запрашиваем разрешение
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        // Показываем диалог о том, что разрешение отклонено
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Доступ к геолокации отклонен'),
              content: const Text(
                  'Для корректной работы приложения необходим доступ к геолокации.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;

      // Показываем диалог о том, что разрешение отклонено навсегда
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Доступ к геолокации отклонен'),
            content: const Text(
                'Для корректной работы приложения необходим доступ к геолокации. Пожалуйста, включите его в настройках устройства.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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
      await _requestLocationPermission();

      final accessToken = await storage.getAccessToken();
      final refreshToken = await storage.getRefreshToken();
      if (accessToken != null) {
        await connectToOnlineStatus(accessToken).catchError((e) {
          developer.log('Ошибка при подключении к WebSocket: $e',
              name: 'INITIAL_SCREEN');
        });
        profile = await ProfileApi().getProfile();
      }

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
      developer.log('Ошибка инициализации: $e', name: 'INITIAL_SCREEN');
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
