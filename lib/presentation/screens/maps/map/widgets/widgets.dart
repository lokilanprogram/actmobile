import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildHeader(String title) => Text(
  title,
  style: TextStyle(
    height: 1,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: 'Gilroy'
  ),
);


Widget buildInfoRow(IconData icon, String dateTimeText, String startTime, String timeEnd,
String address) => Padding(
  padding: EdgeInsets.symmetric(vertical: 8),
  child: Row(crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(children: [
          SvgPicture.asset('assets/icons/icon_time.svg'),
          SizedBox(width: 10,),
          Text('Дата и время', style: TextStyle( color: mainBlueColor,fontWeight: FontWeight.bold, fontFamily: 'Inter', fontSize: 17.8),)
        ],),
        SizedBox(height: 5,),
        Row(children: [
          Text(dateTimeText,style: TextStyle(fontFamily: 'Gilroy',fontSize: 16),),
          SizedBox(width: 10,),
          Text(formatDuration(startTime, timeEnd),style: TextStyle(fontFamily: 'Gilroy',fontSize: 16,color: Colors.grey),)
        ],),
        SizedBox(height: 20,),
          Row(children: [
          SvgPicture.asset('assets/icons/icon_location.svg'),
          SizedBox(width: 10,),
          Text('Место', style: TextStyle( color: mainBlueColor,fontWeight: FontWeight.bold, fontFamily: 'Inter', fontSize: 17.8),)
        ],),
          Row(children: [
          Text(address,style: TextStyle(fontFamily: 'Gilroy',fontSize: 16,color: mainBlueColor,fontWeight: FontWeight.w400),),
        ],)
      ],),
    ],
  ),
);

Widget buildSpotsIndicator(bool isUnlimited, int freeSlots, int slots) => Row(
  children: [
    SvgPicture.asset('assets/icons/icon_people.svg'),
    SizedBox(width: 10),
    Text(
     isUnlimited && slots ==0 ? 'Неограниченно': 'Свободно $freeSlots из $slots мест',
      style: TextStyle(fontSize: 17.8,
        color: mainBlueColor,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
);
