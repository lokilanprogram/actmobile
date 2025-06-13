import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventsAroundScreen extends StatelessWidget {
  const EventsAroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/image_events_around.png"),
                fit: BoxFit.cover,
              ),
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
                  SvgPicture.asset('assets/texts/text_events.svg'),
                  SizedBox(height: 10),
                  SvgPicture.asset('assets/texts/text_find_events.svg'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
