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
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 10,
              runSpacing: 5,
              children: [
                organizedEvent.price == 0
                    ? buildTagBig('Бесплатное')
                    : buildTagBig(organizedEvent.price.toString() + " ₽"),
                // if (organizedEvent.status == 'completed')
                //   buildTagBig('Завершено'),
                if (organizedEvent.restrictions.contains("withKids"))
                  buildTagBig('Можно с детьми'),
                if (organizedEvent.creator.isOrganization ?? false)
                  buildTagBig('Компания'),
                if (organizedEvent.type == 'online') buildTagBig('Онлайн'),
                if (organizedEvent.restrictions.contains("withAnimals"))
                  buildTagBig('Можно с животными'),
                if (organizedEvent.restrictions.contains("isKidsNotAllowed"))
                  buildTagBig('18+'),
              ],
            ),
            SizedBox(height: 15),

            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.network(
                      organizedEvent.photos.first,
                      width: double.infinity,
                      height: 144,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 144,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: mainBlueColor,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )),
            const SizedBox(height: 16),
            buildInfoRow(
                organizedEvent,
                context,
                Icons.calendar_today,
                '${DateFormat('dd.MM.yyyy').format(organizedEvent.dateStart)} | ${organizedEvent.timeStart.substring(0, 5)} – ${organizedEvent.timeEnd.substring(0, 5)}',
                organizedEvent.timeStart,
                organizedEvent.timeEnd,
                organizedEvent.address),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 15),
              child: Divider(
                thickness: 1,
              ),
            ),
            buildSpotsIndicator(
                organizedEvent.restrictions
                    .any((restict) => restict == 'isUnlimited'),
                organizedEvent.freeSlots,
                organizedEvent.slots,
                organizedEvent.participants
                    .where((user) => user.status == 'confirmed')
                    .map((user) => user.user.photoUrl)
                    .toList()),
            const SizedBox(height: 38),
            InkWell(
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EventDetailScreen(eventId: organizedEvent.id)));
              },
              child: Container(
                height: 59,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: mainBlueColor),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                  child: Center(
                      child: Text(
                    'Открыть событие',
                    style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
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

Widget buildTagBig(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 13),
    decoration: BoxDecoration(
      border: Border.all(color: mainBlueColor, width: 1),
      borderRadius: BorderRadius.circular(76),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: Colors.black,
        fontSize: 12.46,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}