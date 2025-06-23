import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventsAroundScreen extends StatelessWidget {
  const EventsAroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/image_events_around.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: height * 0.38,
              right: width * 0.09,
              left: width * 0.09,
            ),
            child: Align(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/texts/text_events.svg',
                    width: width * 0.7,
                  ),
                  SizedBox(height: height * 0.012),
                  SvgPicture.asset(
                    'assets/texts/text_find_events.svg',
                    width: width * 0.7,
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
