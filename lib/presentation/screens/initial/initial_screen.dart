import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/presentation/screens/auth/select_input/select_input_screen.dart';
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
    final profile = await ProfileApi().getProfile(); 
    print('access token ---- $accessToken');
    print('refresh token ---- $refreshToken');
    await Future.delayed(Duration(seconds: 1)).then((_) async {
      if (accessToken != null && refreshToken != null && profile != null) {
        try{
        //   await AuthApi().authRefreshToken().then((token){
        //   if(token != null){
        //      if(isOnboardingCompleted!=null){
        //     Navigator.push(context, MaterialPageRoute(builder: (_)=>MapScreen()));
        //     }else{
        //       Navigator.push(context, MaterialPageRoute(builder: (_)=>EventsAroundScreen()));
        //     }
        //   }
        //  });

          if(profile.categories.isNotEmpty){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>MapScreen()));
            }else{
              Navigator.push(context, MaterialPageRoute(builder: (_)=>EventsAroundScreen()));
            }
       
        }catch(e){
          await deleteAuthTokens();
          Navigator.push(context, MaterialPageRoute(builder: (_)=>SelectInputScreen()));
        }
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (_)=>SelectInputScreen()));
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


