import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/get/my_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyEventsWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const MyEventsWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
          // Обновляем состояние при переходе
          context.read<ProfileBloc>().add(ProfileGetListEventsEvent());
        }
      },
      child: Material(
        elevation: 1.2,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 59,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: mainBlueColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/icon_event_bar.svg'),
              SizedBox(
                width: 10,
              ),
              Text(
                'Мои события',
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
