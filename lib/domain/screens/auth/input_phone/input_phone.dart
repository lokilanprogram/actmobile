import 'package:acti_mobile/configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InputPhoneScreen extends StatelessWidget {
  const InputPhoneScreen({super.key});

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
                Text('Введите ваш номер\nдля входа',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Gilroy',color: authBlueColor,fontSize: 27),),
                SizedBox(height: 10,),
                Text('Вы получите Push-уведомление, которое\nнеобходимо принять',
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontFamily: 'Gilroy',fontSize: 13),),
                SizedBox(height: 15,),
                Container(decoration: BoxDecoration(color: Color.fromRGBO(236, 236, 236,1),borderRadius: BorderRadius.circular(25)),
                  child: TextFormField(
                    decoration: InputDecoration(hintText: 'Телефон',prefixIcon: Icon(Icons.phone,color: mainBlueColor,),
                      enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: Colors.white)) ,
                     focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  ),
                  SizedBox(height: 15,),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),color: mainBlueColor),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                          child: Text('Мне 18 лет',style: TextStyle(color: Colors.white,fontFamily: 'Inter'),),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: mainBlueColor), borderRadius: BorderRadius.circular(25),color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14,),
                          child: Text('Мне 18 лет',style: TextStyle(color: mainBlueColor,fontFamily: 'Inter'),),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                ],
                ),
              )
            ],
          
        )),
      ),
    );
  }
}