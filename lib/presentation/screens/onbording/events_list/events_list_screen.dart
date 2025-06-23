import 'package:flutter/material.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
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
            top: height * 0.13,
            left: width * 0.05,
            right: width * 0.05,
            child: Image.asset(
              'assets/images/onboard_card.png',
              width: width * 0.9,
            ),
          ),
          Positioned(
            top: height * 0.42,
            left: width * 0.05,
            right: width * 0.05,
            child: Image.asset(
              'assets/images/onboard_card1.png',
              width: width * 0.9,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: height * 0.5,
              right: width * 0.1,
              left: width * 0.1,
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
                      fontSize: width * 0.085,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w800,
                      height: 0.7,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    "Выбирай понравившееся событие, знакомься \nи наслаждайся вместе с Acti",
                    style: TextStyle(
                      letterSpacing: 0.5,
                      color: Colors.white,
                      fontSize: width * 0.045,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w400,
                      height: 0.9,
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
