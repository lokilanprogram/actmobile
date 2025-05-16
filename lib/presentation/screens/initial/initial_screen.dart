import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/domain/api/auth/auth_api.dart';
import 'package:acti_mobile/presentation/screens/auth/input_phone/input_phone.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_around/events_around_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
   initialize();
    super.initState();
  }

  initialize() async {
    final accessToken = await storage.read(key: accessStorageToken);
    final refreshToken = await storage.read(key: refreshStorageToken);
    final isOnboardingCompleted = await storage.read(key: isOnboardingCompletedFlag);
    print('access token ---- $accessToken');
    print('refresh token ---- $refreshToken');
    await Future.delayed(Duration(seconds: 1)).then((_) async {
      if (accessToken != null && refreshToken != null) {
        try{
        //   await AuthApi().authRefreshToken().then((token){
        //   if(token != null){
           
        //   }
        //  });
         if(isOnboardingCompleted!=null){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>MapScreen()));
            }else{
              Navigator.push(context, MaterialPageRoute(builder: (_)=>EventsAroundScreen()));
            }
        }catch(e){
          await deleteAuthTokens();
          Navigator.push(context, MaterialPageRoute(builder: (_)=>InputPhoneScreen()));
        }
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (_)=>InputPhoneScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      body: LoaderWidget()
    );
  }
}


