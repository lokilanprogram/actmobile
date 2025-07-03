import 'package:flutter/material.dart';
import 'dart:math';

class EventsCreateScreen extends StatelessWidget {
  const EventsCreateScreen({super.key});

  double _getFontSize(
      BuildContext context, double small, double medium, double large) {
    final size = MediaQuery.of(context).size;
    final diagonal =
        sqrt((size.width * size.width + size.height * size.height));
    final screenInches =
        diagonal / 100; // Простой коэффициент для перевода в дюймы

    print('DEBUG: width=${size.width}, height=${size.height}');
    print('DEBUG: diagonal=$diagonal, screenInches=$screenInches');

    if (screenInches <= 5.3) {
      print('DEBUG: Using small font size');
      return small;
    }
    if (screenInches <= 6.0) {
      print('DEBUG: Using medium font size');
      return medium;
    }
    if (screenInches <= 6.7) {
      print('DEBUG: Using large font size');
      return large;
    }
    print('DEBUG: Using large font size (default)');
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
            40,
            40,
            40,
            70,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/onboard_card2.png',
                  height: height * 0.55,
                  width: width * 0.8,
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Создавай \nактивность",
                      style: TextStyle(
                        letterSpacing: 0.01,
                        color: Colors.white,
                        fontSize: _getFontSize(context, 18, 22, 35),
                        fontFamily: "Gilroy",
                        fontWeight: FontWeight.w700,
                        height: 0.7,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Если не нашли интересующее вас, создайте свою активность! \nМы уверены, вы соберёте команду единомышленников",
                      style: TextStyle(
                        letterSpacing: 0.1,
                        color: Colors.white,
                        fontSize: _getFontSize(context, 11, 13, 18),
                        fontFamily: "Gilroy",
                        fontWeight: FontWeight.w400,
                        height: 0.9,
                      ),
                    ),
                  ],
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
