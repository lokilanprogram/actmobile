import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/widgets/pop_nav_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventsStartScreen extends StatelessWidget {
  const EventsStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor:Color.fromARGB(255, 188, 219, 253), //Color.fromARGB(255,81,156,241),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: Container(
                color: Color.fromARGB(255, 188, 219, 253),
              )),
              Expanded(
                  child: Container(
                color: Color.fromARGB(255, 81, 156, 241),
              )),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/image_start_events.png",
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
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
                  SvgPicture.asset('assets/texts/text_events_start.svg'),
                  SizedBox(
                    height: 30,
                  ),
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
                          function: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => InitialScreen()));
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
