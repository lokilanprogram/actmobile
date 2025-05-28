import 'dart:io';

import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/domain/bloc/chat/chat_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(
      'pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg');
   await Firebase.initializeApp(options: FirebaseOptions( 
          apiKey:Platform.isAndroid ? "AIzaSyBSPx33YxNkVQ9m5nb_U3Uchu1YpoiDSOg":"AIzaSyBhorOPzeLBM2gICrTlhw32hEmOpjGcZkM",
          appId: Platform.isAndroid ? "1:927589486813:android:2315c019c7bf66d4a40b34" : "1:368466897752:ios:d78a2747650774472dd32d",
          messagingSenderId: "927589486813",
          projectId: "acti-54f96"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
         BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(),
        ),
        ],
      child: GetMaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: InitialScreen(
        ),
      ),
    );
  }
}
