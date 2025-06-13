import 'package:flutter/material.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE0F2F7),
                  Color.fromARGB(255, 66, 147, 239),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Image.asset(
              'assets/images/onboard_card.png',
            ),
          ),
          Positioned(
            top: 320,
            left: 20,
            right: 20,
            child: Image.asset(
              'assets/images/onboard_card1.png',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.6,
              right: 40,
              left: 40,
            ),
            child: Align(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Список мероприятий",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w800,
                      height: 0.7,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Выбирай понравившееся событие, знакомься \nи наслаждайся вместе с Acti",
                    style: TextStyle(
                      letterSpacing: 0.5,
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w400,
                      height: 0.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
