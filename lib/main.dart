import 'package:acti_mobile/domain/bloc/acti_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(
      'pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d3I0aTIxaW01MmtxejRvZ2xjcTdkIn0.anabmk9LvdPr59DxH9cB3Q');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ActiBloc>(
          create: (context) => ActiBloc(),
        ),
         BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
        ),
        ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: InitialScreen(
        ),
      ),
    );
  }
}
