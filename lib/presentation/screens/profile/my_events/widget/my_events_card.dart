import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/widget/event_detail_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class MyCardEventWidget extends StatelessWidget {
  final ProfileEventModel profileEventModel;
  const MyCardEventWidget({
    super.key, required this.profileEventModel
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_)=>EventDetailHomeScreen(
          eventId: profileEventModel.id,
        )));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Card(elevation: 0.6,color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15)
          ),
                child: Image.network('http://93.183.81.104${profileEventModel.photos.first}',
                width: 130,
                height: 215,
                fit: BoxFit.cover,),
              ),
                SizedBox(width: 10,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(profileEventModel.title,style: TextStyle(
                            height: 1,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Gilroy'
                                                      ),),
                          ),
                          SizedBox(width: 5,),
                      Row(children: [SvgPicture.asset('assets/icons/icon_adult.svg'),   
                      InkWell(onTap: (){}, child: Icon(Icons.more_vert))   ],)               
                        ],
                      ),
                            SizedBox(height: 5,),
                     Row(children: [
                            Text(DateFormat('dd.MM.yyyy').format(profileEventModel.dateStart),style: TextStyle(fontFamily: 'Gilroy',fontSize: 11.89,color: mainBlueColor,fontWeight: FontWeight.w700),),
                            SizedBox(width: 5,),
                            Text('|',style: TextStyle(color: mainBlueColor),),
                            SizedBox(width: 5,),
                            Text('${profileEventModel.timeStart.substring(0,5)}-${profileEventModel.timeEnd.substring(0,5)}',style: TextStyle(fontFamily: 'Gilroy',fontSize: 11.89,color: mainBlueColor,fontWeight: FontWeight.w700),),
                          ],),
                            SizedBox(height: 5,),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
height: 45,                        child: Text(profileEventModel.description,style: TextStyle(
                            fontFamily: 'Gilroy',fontSize: 12,fontWeight: FontWeight.w400,
                           ),overflow: TextOverflow.ellipsis,maxLines: 3,),
                      ),
                    ),
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