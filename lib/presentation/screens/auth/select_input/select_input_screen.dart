import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/presentation/screens/auth/input_phone/input_phone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SelectInputScreen extends StatelessWidget {
  const SelectInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.white,
        body:GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
              child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/image_background.png",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 120, left: 45, right: 45),
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.topCenter,
                        child: SvgPicture.asset('assets/icons/icon_acti.svg')),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Войти в приложение',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Gilroy',
                          color: authBlueColor,
                          fontSize: 27),
                    ),
                    SizedBox(
                      height: 45,
                    ),
                    Text(
                      'Через сервис',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Gilroy', fontSize: 20,fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row( mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      SvgPicture.asset('assets/icons/icon_yandex_id.svg'),
                      SizedBox(width: 15,),
                      SvgPicture.asset('assets/icons/icon_vk_id.svg'),
                    ],),
                        Spacer(),
                  InkWell(
                      onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> InputPhoneScreen()));
                      },
                      child: Container(
                        height: 59,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: mainBlueColor),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                          child: Center(
                              child: Text(
                            'По номеру телефона',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Inter'),
                          )),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SvgPicture.asset('assets/texts/text_confirm.svg'),
                  ],
                ),
              )
            ],
          )),
        ),
      );
  }
}