import 'package:acti_mobile/presentation/screens/onbording/events_select/events_select_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/widgets/pop_nav_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventsCreateScreen extends StatelessWidget {
  const EventsCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE0F2F7), // Light blue from the image
                  Color.fromARGB(
                      255, 66, 147, 239), // Slightly darker blue from the image
                ], // Adjust colors as needed
              ),
            ),
          ),
          // Event Card 1 (Placeholder for PNG)
          Positioned(
            top: 100, // Adjust position as needed
            left: 20, // Adjust position as needed
            right: 20, // Adjust position as needed
            child: Image.asset(
              height: 420,
              'assets/images/onboard_card2.png', // Replace with your actual image path
              // fit: BoxFit.contain, // Adjust fit as needed
            ),
          ),
          // child: SvgPicture.asset("assets/images/onboard_card.svg")),
          // Event Card 2 (Placeholder for PNG)
          // Positioned(
          //   top: 320, // Adjust position as needed
          //   left: 20, // Adjust position as needed
          //   right: 20, // Adjust position as needed
          //   child: Image.asset(
          //     'assets/images/onboard_card1.png', // Replace with your actual image path
          //     // fit: BoxFit.contain, // Adjust fit as needed
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.6,
                right: 40,
                left: 40),
            child: Align(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Создавай активность",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontFamily: "Gilroy",
                        fontWeight: FontWeight.w800,
                        height: 0.7),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Если не нашли интересующее вас, создайте свою активность! Мы уверены, вы соберёте команду единомышленников",
                    style: TextStyle(
                        letterSpacing: 0.5,
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: "Gilroy",
                        fontWeight: FontWeight.w400,
                        height: 0.9),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  // Здесь нужно ставить текст
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: PopNavButton(
                          text: 'Назад',
                          function: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: PopNavButton(
                          text: 'Далее',
                          function: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EventsSelectScreen(
                                          fromUpdate: false,
                                        )));
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
