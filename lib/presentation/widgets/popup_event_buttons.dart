import 'package:acti_mobile/configs/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PopUpPublicUserButtons extends StatelessWidget {
  final Function blockFunction;
  final String userName;
  final String userId;
  const PopUpPublicUserButtons({
    super.key, required this.blockFunction, required this.userName,required this.userId
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
                showBlockDialog(context, userName, blockFunction);
              },
              child: Row(
                children:  [
                  SvgPicture.asset('assets/icons/icon_block.svg'),
                  SizedBox(width: 10),
                  Text("Заблокировать",style: TextStyle(
                    fontFamily: 'Gilroy',fontSize: 12.93,
                  ),),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              onTap: (){
                showReportUserBottomSheet(context,userId);
              },
              child: Row(
                children:  [
                  SvgPicture.asset('assets/icons/icon_complain.svg'),
                  SizedBox(width: 10),
                  Text("Пожаловаться",style: TextStyle(
                    fontFamily: 'Gilroy',fontSize: 12.93,
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



class PopUpEventButtons extends StatelessWidget {
  final Function blockFunction;
  final String eventId;
  const PopUpEventButtons({
    super.key, required this.blockFunction,required this.eventId
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
              },
              child: Row(
                children:  [
                  SvgPicture.asset('assets/icons/icon_share.svg'),
                  SizedBox(width: 10),
                  Text("Поделиться",style: TextStyle(
                    fontFamily: 'Gilroy',fontSize: 12.93,
                  ),),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              onTap: (){
                showReportEventBottomSheet(context,eventId );
              },
              child: Row(
                children:  [
                  SvgPicture.asset('assets/icons/icon_block.svg',color: Colors.red,),
                  SizedBox(width: 10),
                  Text("Пожаловаться",style: TextStyle(
                    fontFamily: 'Gilroy',fontSize: 12.93,
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


