import 'package:acti_mobile/configs/events.dart';
import 'package:acti_mobile/domain/screens/onbording/events_start/events_start_screen.dart';
import 'package:acti_mobile/domain/screens/onbording/widgets/pop_nav_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventsSelectScreen extends StatelessWidget {
  const EventsSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/image_select_event.png",),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
       Padding(
  padding: EdgeInsets.only(
    right: 40,
    left: 40,
  ),
  child: SingleChildScrollView(physics: NeverScrollableScrollPhysics(),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 24,
              childAspectRatio: 3.5,
              children: events
                  .map((event) => InkWell(
                    onTap: (){
                      print(event.name);
                    },
                    child: SvgPicture.asset(event.iconPath)))
                  .toList(),
            ),
          
          Center(child: SvgPicture.asset('assets/texts/text_select_event.svg')),
          const SizedBox(height: 55),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopNavButton(
                text: 'Назад',
                function: () {
                  Navigator.pop(context);
                },
              ),
              PopNavButton(
                text: 'Далее',
                function: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> EventsStartScreen()));
                },
              ),
            ],
          )
        ],
      ),
    ),
  ),
)

         
          ],
        ),
      
    );
  }
}

