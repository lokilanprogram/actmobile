import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/auth_codes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';

class InputCodeScreen extends StatefulWidget {
  final AuthCodes authCodes;
  const InputCodeScreen({super.key, required this.authCodes});

  @override
  State<InputCodeScreen> createState() => _InputCodeScreenState();
}

class _InputCodeScreenState extends State<InputCodeScreen> {
  late TextEditingController codeController;
  @override
  void initState() {
    setState(() {
      codeController = TextEditingController(text: widget.authCodes.smsCode);
    });
    super.initState();
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
               SizedBox(height: 30,),
                Text('На ваш номер телефона поступит звонок',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Gilroy',color: authBlueColor,fontSize: 18),),
                SizedBox(height: 10,),
                Text('Введите последние 4 цифры номера\n(можете не принимать звонок)',
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontFamily: 'Gilroy',fontSize: 13),),
                    SizedBox(height: 15,),
                Pinput(length: 4,defaultPinTheme: PinTheme(width: 56,
  height: 56,
  textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
  decoration: BoxDecoration(color: Colors.white,
    border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
    borderRadius: BorderRadius.circular(10),
  ),
                ),
                controller: codeController,
                    onCompleted: (pin) => print(pin),
                  ),
                  SizedBox(height: 15,),
                  SvgPicture.asset('assets/texts/text_support.svg'),
                  SizedBox(height: 15,),
                  Container(height: 59, width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),color: mainBlueColor),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                          child: Center(child: Text('Войти',style: TextStyle(color: Colors.white,fontFamily: 'Inter'),)),
                        ),
                      ),
                ],
                ),
              )
            ],
          
        )),
      ),
    );
  }
}