import 'package:flutter/material.dart';

class EventsCreateScreen extends StatelessWidget {
  const EventsCreateScreen({super.key});

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
            top: height * 0.15,
            left: width * 0.05,
            right: width * 0.05,
            child: Image.asset(
              height: height * 0.45,
              width: width * 0.9,
              'assets/images/onboard_card2.png',
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
                    "Создавай активность",
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
                    "Если не нашли интересующее вас, создайте свою активность! Мы уверены, вы соберёте команду единомышленников",
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
