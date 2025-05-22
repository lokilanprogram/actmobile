import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/create_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SendMessageBarWidget extends StatelessWidget {
  const SendMessageBarWidget({
    super.key,
    required this.function
  });
  final Function function;


  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: (){
          function();
        },
        child: Material(
          elevation: 1.2,
          borderRadius: BorderRadius.circular(25),
          child: Container(  height: 59,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: mainBlueColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        SvgPicture.asset('assets/icons/icon_chat.svg'),
                        SizedBox(width: 10,),
                        Text('Написать сообщение',style: TextStyle(color: Colors.white,
                        fontFamily: 'Gilroy',fontSize: 17,fontWeight: FontWeight.bold),)
                      ],),
            
            
          ),
        ),
      );
  }
}

