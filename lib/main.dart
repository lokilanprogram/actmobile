import 'dart:io';

import 'package:acti_mobile/configs/settings_notifier.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/domain/bloc/chat/chat_bloc.dart';
import 'package:acti_mobile/domain/bloc/notifications/notifications_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/domain/repositories/auth_repository.dart';
import 'package:acti_mobile/domain/services/auth_service.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/screens/events/providers/filter_provider.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:acti_mobile/presentation/screens/events/providers/vote_provider.dart';
import 'package:acti_mobile/configs/constants.dart';

final baseUrl = API;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(
      'pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg');
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: Platform.isAndroid
              ? "AIzaSyBSPx33YxNkVQ9m5nb_U3Uchu1YpoiDSOg"
              : "AIzaSyBhorOPzeLBM2gICrTlhw32hEmOpjGcZkM",
          appId: Platform.isAndroid
              ? "1:927589486813:android:2315c019c7bf66d4a40b34"
              : "1:368466897752:ios:d78a2747650774472dd32d",
          messagingSenderId: "927589486813",
          projectId: "acti-54f96"));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        ChangeNotifierProvider<FilterProvider>(
          create: (context) => FilterProvider(),
        ),
        ChangeNotifierProvider<VoteProvider>(
          create: (context) => VoteProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsNotificationsProvider()..loadProfile(),
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
                MaterialPageRoute(
                    builder: (_) => MapScreen(selectedScreenIndex: 0)),
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
