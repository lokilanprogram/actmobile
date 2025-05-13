import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PopUpEventButtons extends StatelessWidget {
  final Function function;
  const PopUpEventButtons({
    super.key, required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          offset: const Offset(-10, 50),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<int>(
              value: 0,
              child: Row(
                children:  [
                  SvgPicture.asset('assets/icons/icon_share.svg'),
                  SizedBox(width: 10),
                  Text("Поделиться",style: TextStyle(
                    fontFamily: 'Inter',fontSize: 15.73,
                  ),),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children:  [
                  SvgPicture.asset('assets/icons/icon_complain.svg'),
                  SizedBox(width: 10),
                  Text("Пожаловаться",style: TextStyle(
                    fontFamily: 'Inter',fontSize: 15.73,
                    color: Colors.red
                  ),),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert, color: Colors.white),
        );
  }
}


