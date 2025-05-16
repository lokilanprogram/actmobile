import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PopUpProfileButtons extends StatelessWidget {
  final Function editFunction;
  final Function deleteFunction;
  const PopUpProfileButtons({
    super.key, required this.editFunction,required this.deleteFunction
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
              onTap: (){
                editFunction();
              },
              child: Row(
                children:  [
                  SvgPicture.asset('assets/icons/icon_edit.svg'),
                  SizedBox(width: 10),
                  Text("Редактировать профиль",style: TextStyle(
                    fontFamily: 'Gilroy',fontSize: 13
                  ),),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children:  [
                  SvgPicture.asset('assets/icons/icon_settings.svg'),
                  SizedBox(width: 10),
                  Text("Настройки",style: TextStyle(
                    fontFamily: 'Gilroy',fontSize: 13
                  ),),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              onTap: (){
                deleteFunction();
              },
              child: Row(
                children:  [
                  SvgPicture.asset('assets/icons/icon_exit.svg'),
                  SizedBox(width: 10),
                  Text("Выход",style: TextStyle(
                    fontFamily: 'Gilroy',fontSize: 13
                  ),),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert, color: Colors.white),
        );
  }
}


