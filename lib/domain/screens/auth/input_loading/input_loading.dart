import 'dart:async';

import 'package:acti_mobile/domain/screens/auth/input_loading/rotating_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InputLoadingScreen extends StatefulWidget {
  const InputLoadingScreen({super.key});

  @override
  State<InputLoadingScreen> createState() => _InputLoadingScreenState();
}

class _InputLoadingScreenState extends State<InputLoadingScreen> {
  final codeController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 30;

@override
  void initState() {
    startTimer();
    super.initState();
  }
   void startTimer() {
     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer!.cancel();
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(child:  Stack(
            children: [
              Align(alignment: Alignment.topCenter,
                child: Container(height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/image_background.png",),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 120,left: 45, right: 45),
                child: Column(
                  children: [
               Align(alignment: Alignment.topCenter, child: SvgPicture.asset('assets/icons/icon_acti.svg')),
               SizedBox(height: 90,),
               RotatingIcon(),
               SizedBox(height: 15,),
                Text('Ожидания подтверждения',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Gilroy',color: Colors.black,fontSize: 18),),
                SizedBox(height: 5,),
                Text('00:${_remainingSeconds.toString()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Gilroy',color: Colors.black,fontSize: 20),),
                SizedBox(height: 10,),
                SvgPicture.asset('assets/texts/text_redirect.svg')
                ],
                ),
              )
            ],
          
        )),
      ),
    );
  }
}