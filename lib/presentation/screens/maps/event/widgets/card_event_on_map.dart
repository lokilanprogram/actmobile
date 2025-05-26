import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/widgets.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/widget/my_events_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class CardEventOnMap extends StatelessWidget {
  final OrganizedEventModel organizedEvent;
  const CardEventOnMap({super.key, required this.organizedEvent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SvgPicture.asset('assets/icons/icon_divider_sheet.svg'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: buildHeader(organizedEvent.title)),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  Image.network(organizedEvent.photos.first,width: double.infinity,height:144,fit: BoxFit.cover,),
                 organizedEvent.price == 0? Positioned(left: 10,top: 5,
                    child: RestrictionContainer(text: 'Бесплатное')):Container(),
                 organizedEvent.restrictions.any((element)=>
                 element =='isAdults')? Positioned(right: 10,top: 5,
                    child: SvgPicture.asset('assets/icons/icon_adult_white.svg')):Container(),
                ],
              )),
            const SizedBox(height: 16),
            buildInfoRow(Icons.calendar_today, '${DateFormat('dd.MM.yyyy').format(organizedEvent.dateStart)} | ${organizedEvent.timeStart.substring(0,5)} – ${organizedEvent.timeEnd.substring(0,5)}',
            organizedEvent.timeStart, organizedEvent.timeEnd, organizedEvent.address),
            const SizedBox(height: 16),
            buildSpotsIndicator(organizedEvent.restrictions.any((restict)=> restict == 'isUnlimited'), organizedEvent.freeSlots, organizedEvent.slots),
            const SizedBox(height: 38),
            InkWell(onTap: () async{
             Navigator.push(context, MaterialPageRoute(builder: (context)=>
              EventDetailScreen(eventId: organizedEvent.id)));
                        },
                        child: Container(
                          height: 59,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: mainBlueColor),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 14),
                            child: Center(
                                child: Text(
                              'Открыть события',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'Inter'),
                            )),
                          ),
                        ),
                      ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
