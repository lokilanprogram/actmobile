import 'package:acti_mobile/configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildHeader() => Text(
  'Играем в уличный\nбаскетбол',
  style: TextStyle(
    height: 1,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: 'Gilroy'
  ),
);


Widget buildInfoRow(IconData icon, String text) => Padding(
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
          Text('20.10.2024',style: TextStyle(fontFamily: 'Gilroy',fontSize: 16),),
          SizedBox(width: 10,),
          Text('|'),
          SizedBox(width: 10,),
          Text('18:00-18:40',style: TextStyle(fontFamily: 'Gilroy',fontSize: 16),),
          SizedBox(width: 10,),
          Text('40 мин',style: TextStyle(fontFamily: 'Gilroy',fontSize: 16,color: Colors.grey),)
        ],),
        SizedBox(height: 20,),
          Row(children: [
          SvgPicture.asset('assets/icons/icon_location.svg'),
          SizedBox(width: 10,),
          Text('Место', style: TextStyle( color: mainBlueColor,fontWeight: FontWeight.bold, fontFamily: 'Inter', fontSize: 17.8),)
        ],),
          Row(children: [
          Text('г. Москва, ул. Тверская, д. 6',style: TextStyle(fontFamily: 'Gilroy',fontSize: 16,color: mainBlueColor,fontWeight: FontWeight.w400),),
        ],)
      ],),
      Image.asset('assets/icons/icon_users.png')
    ],
  ),
);

Widget buildSpotsIndicator() => Row(
  children: [
    SvgPicture.asset('assets/icons/icon_people.svg'),
    SizedBox(width: 10),
    Text(
      'Свободно 5 из 10 мест',
      style: TextStyle(fontSize: 17.8,
        color: mainBlueColor,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
);
