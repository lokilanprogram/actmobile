import 'package:flutter/material.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F2F7),
              Color.fromARGB(255, 66, 147, 239),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: height * 0.07,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/onboard_card.png',
                    width: width * 0.95,
                  ),
                ),
                // SizedBox(height: height * 0.03),
                Center(
                  child: Image.asset(
                    'assets/images/onboard_card1.png',
                    width: width * 0.95,
                  ),
                ),
                // SizedBox(height: height * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Список \nмероприятий",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.09,
                          fontFamily: "Gilroy",
                          fontWeight: FontWeight.w700,
                          height: 0.8,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        "Выбирай понравившееся событие, знакомься и наслаждайся вместе с \nActi",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
