import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventsHomeListOnMapWidget extends StatelessWidget {
  final ScrollController scrollController;
  const EventsHomeListOnMapWidget({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20,),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
                children:  [
                  SizedBox(height: 20,),
                  Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                  //  CardEventWidget(),
                  // CardEventWidget(),
                  // CardEventWidget(),
                  // CardEventWidget(),
                  // CardEventWidget(),
                ],
              
            ),
      ),
    );
  }
}


class CardEventWidget extends StatelessWidget {
  const CardEventWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
      //  Navigator.push(context, MaterialPageRoute(builder: (_)=>EventDetailScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Card(elevation: 0.6,color: Colors.white,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/image_acti_card.png'),
                SizedBox(width: 10,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Играем в уличный\nбаскетбол',style: TextStyle(
                          height: 1,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Gilroy'
                                                    ),),
                      Row(children: [SvgPicture.asset('assets/icons/icon_adult.svg'),   
                      InkWell(onTap: (){}, child: Icon(Icons.more_vert))   ],)               
                        ],
                      ),
                            SizedBox(height: 5,),
                     Row(children: [
                            Text('20.10.2024',style: TextStyle(fontFamily: 'Gilroy',fontSize: 11.89,color: mainBlueColor,fontWeight: FontWeight.w700),),
                            SizedBox(width: 5,),
                            Text('|',style: TextStyle(color: mainBlueColor),),
                            SizedBox(width: 5,),
                            Text('18:00-18:40',style: TextStyle(fontFamily: 'Gilroy',fontSize: 11.89,color: mainBlueColor,fontWeight: FontWeight.w700),),
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
                       'Свободно  из 10 мест',
                       style: TextStyle(fontSize: 11,
                         color: mainBlueColor,
                         fontWeight: FontWeight.w600,
                       ),
                     ),
                   ],
                 ),
               
                            SizedBox(height: 10,),
                            Row(
                              children: [
                              Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),color: mainBlueColor),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 14),
                                child: Text('Бесплатное',style: TextStyle(color: Colors.white,fontFamily: 'Gilroy',fontSize: 9.87),),
                              ),),
                            SizedBox(width: 10,),
                              Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),color: mainBlueColor),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 12),
                                child: Text('Компания',style: TextStyle(color: Colors.white,fontFamily: 'Gilroy',fontSize: 9.87),),
                              ),),
                            ],)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}