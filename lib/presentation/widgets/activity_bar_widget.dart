import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/create_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActivityBarWidget extends StatelessWidget {
  const ActivityBarWidget({
    super.key,
    required this.isVerified,
    required this.isProfileCompleted,
  });

  final bool isVerified;
  final bool isProfileCompleted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        isVerified
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateEventScreen(
                          organizedEventModel: null,
                        )))
            : showAlertOKDialog(context, null,
                isTitled: true, title: 'Подтвердите почту');
      },
      child: Material(
        elevation: 1.2,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 59,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Color.fromRGBO(98, 207, 102, 1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/icon_add.svg'),
              SizedBox(
                width: 10,
              ),
              Text(
                'Создать активность',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Gilroy',
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}
