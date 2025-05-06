import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/domain/screens/maps/map/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventsHomeWidget extends StatelessWidget {
  const EventsHomeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
    height: MediaQuery.of(context).size.height * 0.8,
     padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      
    ),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SvgPicture.asset('assets/icons/icon_divider_sheet.svg'),
          ),),
         Expanded(
           child: ListView(shrinkWrap: true,
            children: [
              Card(elevation: 0.6,color: Colors.white,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/image_acti_card.png'),
        SizedBox(width: 10,),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20,bottom: 20),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Играем в уличный\nбаскетбол',style: TextStyle(
                            height: 1,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Gilroy'
                          ),),
                                  SizedBox(height: 5,),
                           Row(children: [
                                  Text('20.10.2024',style: TextStyle(fontFamily: 'Gilroy',fontSize: 12,color: mainBlueColor),),
                                  SizedBox(width: 10,),
                                  Text('|'),
                                  SizedBox(width: 10,),
                                  Text('18:00-18:40',style: TextStyle(fontFamily: 'Gilroy',fontSize: 12,color: mainBlueColor),),
                                ],),
                                  SizedBox(height: 5,),
                          Text('Привет! Я хочу собрать компанию для игры в баскетбол. Это отличный...',style: TextStyle(
                            fontFamily: 'Gilroy',fontSize: 12,fontWeight: FontWeight.w400
                          ),),
                                  SizedBox(height: 5,),
                    Image.asset('assets/images/image_group_people.png'),
                                  SizedBox(height: 10,),
                     Row(
  children: [
    SvgPicture.asset('assets/icons/icon_people.svg'),
    SizedBox(width: 10),
    Text(
      'Свободно 5 из 10 мест',
      style: TextStyle(fontSize: 11,
        color: mainBlueColor,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
),
                                  SizedBox(height: 10,),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
           ),
         )
        ],
      ),
      );
  }
}