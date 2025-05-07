import 'package:acti_mobile/domain/bloc/acti_bloc.dart';
import 'package:acti_mobile/presentation/screens/auth/input_code/input_code.dart';
import 'package:acti_mobile/presentation/screens/auth/input_loading/input_loading.dart';
import 'package:acti_mobile/presentation/screens/auth/input_phone/input_phone.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_around/events_around_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_create/events_create_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_list/events_list_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_select/events_select_screen.dart';
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
    return BlocProvider(
      create: (context) => ActiBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const InputPhoneScreen(),
      ),
    );
  }
}
