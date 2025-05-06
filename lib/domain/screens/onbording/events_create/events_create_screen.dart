import 'package:acti_mobile/domain/screens/onbording/events_select/events_select_screen.dart';
import 'package:acti_mobile/domain/screens/onbording/widgets/pop_nav_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventsCreateScreen extends StatelessWidget {
  const EventsCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/image_create_event.png",),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
         Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.6,right: 40,left: 40),
             child: Align(
               child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset('assets/texts/text_create_event.svg'),
                  SizedBox(height: 10,),
                  SvgPicture.asset('assets/texts/text_find_friends.svg'),
                  SizedBox(height: 30,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: PopNavButton(
                          text: 'Назад',
                          function: (){
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: PopNavButton(
                          text: 'Далее',
                          function: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> EventsSelectScreen()));
                          
                          },
                        ),
                      ),
                    ],
                  )
                ],
               ),
             ),
           ),
         
          ],
        ),
      
    );
  }
}

