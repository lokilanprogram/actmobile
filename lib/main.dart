import 'dart:io';

import 'package:acti_mobile/configs/settings_notifier.dart';
import 'package:acti_mobile/configs/unread_message_provider.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/domain/bloc/chat/chat_bloc.dart';
import 'package:acti_mobile/domain/bloc/notifications/notifications_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/domain/repositories/auth_repository.dart';
import 'package:acti_mobile/domain/services/auth_service.dart';
import 'package:acti_mobile/domain/services/map_optimization_service.dart';
import 'package:acti_mobile/presentation/screens/events/providers/filter_provider.dart';
import 'package:acti_mobile/presentation/screens/events/providers/vote_provider.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen_provider.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/deeplink_service.dart';
import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:acti_mobile/presentation/screens/maps/map/bloc/map_bloc.dart';
import 'package:acti_mobile/domain/services/token_refresh_service.dart';

final baseUrl = API;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Обработчик фоновых уведомлений Firebase
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  MapboxOptions.setAccessToken(
      'pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg');
  
  // Сначала инициализируем Firebase
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: Platform.isAndroid
              ? "AIzaSyBSPx33YxNkVQ9m5nb_U3Uchu1YpoiDSOg"
              : "AIzaSyCjLnxLzxmKKbSCj7ebabQFabmZEvFdf5k",
          appId: Platform.isAndroid
              ? "1:927589486813:android:2315c019c7bf66d4a40b34"
              : "1:927589486813:ios:f0ce8032174c9c6ca40b34",
          messagingSenderId: "927589486813",
          projectId: "acti-54f96"));

  // Затем регистрируем обработчик фоновых уведомлений
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Запуск автообновления токена
  await TokenRefreshService().start();

  // Инициализация сервиса оптимизации карты
  try {
    final mapOptimizationService = MapOptimizationService();
    // Только быстрая инициализация без предварительной загрузки
    await mapOptimizationService.quickInitialize();
    developer.log('Сервис оптимизации карты быстро инициализирован',
        name: 'MAIN');
  } catch (e) {
    developer.log('Ошибка инициализации сервиса оптимизации карты: $e',
        name: 'MAIN');
  }

  final deeplinkService = DeeplinkService();
  await deeplinkService.initDeeplink();

  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    final authRepository = AuthRepository(AuthService(dio, baseUrl));

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(),
        ),
        BlocProvider<MapBloc>(
          create: (context) => MapBloc(),
        ),
        ChangeNotifierProvider<FilterProvider>(
          create: (context) => FilterProvider(),
        ),
        ChangeNotifierProvider<VoteProvider>(
          create: (context) => VoteProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsNotificationsProvider()..loadProfile(),
        ),
        ChangeNotifierProvider(
          create: (_) => MainScreenProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UnreadMessageProvider(),
          child: MyApp(navigatorKey: navigatorKey),
        ),
      ],
      child: GetMaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('ru', ''), // Russian
          const Locale('en', ''), // English
        ],
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            }
          },
          child: InitialScreen(),
        ),
      ),
    );
  }
}
