import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventsStartScreen extends StatelessWidget {
  const EventsStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 188, 219, 253),
              Color.fromARGB(255, 81, 156, 241),
            ],
          ),
          image: DecorationImage(
            image: AssetImage("assets/images/image_start_events.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
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
                SvgPicture.asset('assets/texts/text_events_start.svg',
                    width: width * 0.7),
                SizedBox(height: height * 0.04),
                // Center(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       // Получаем родительский OnboardingsScreen и вызываем _nextPage
                //       Navigator.of(context)
                //           .maybePop(); // Просто для примера, заменим на вызов _nextPage через callback
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Color.fromARGB(255, 66, 147, 239),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(16),
                //       ),
                //       padding: EdgeInsets.symmetric(
                //           horizontal: width * 0.18, vertical: height * 0.022),
                //     ),
                //     child: Text(
                //       'Завершить',
                //       style: TextStyle(
                //         color: Colors.white,
                //         fontSize: width * 0.055,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
