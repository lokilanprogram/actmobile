import 'package:flutter/material.dart';
import 'dart:math';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  double _getFontSize(
      BuildContext context, double small, double medium, double large) {
    final size = MediaQuery.of(context).size;
    final diagonal =
        sqrt((size.width * size.width + size.height * size.height));
    final screenInches =
        diagonal / 100; // Простой коэффициент для перевода в дюймы

    if (screenInches <= 5.3) return small;
    if (screenInches <= 6.0) return medium;
    if (screenInches <= 6.7) return large;
    return large;
  }

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
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            0,
            20,
            0,
            70,
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

              Spacer(),

              Padding(
                padding: EdgeInsets.only(left: 40),
                child: Text(
                  "Список \nмероприятий",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getFontSize(context, 18, 22, 35),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w700,
                    height: 0.8,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 40),
                child: Text(
                  "Выбирай понравившееся событие, знакомься и наслаждайся вместе с \nActi",
                  style: TextStyle(
                    letterSpacing: 0.5,
                    color: Colors.white,
                    fontSize: _getFontSize(context, 11, 13, 18),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w400,
                    height: 0.9,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
