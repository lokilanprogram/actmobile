import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/date_utils.dart' as custom_date;
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/status_model.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/create_event_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/detail/event_detail_home_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/widget/drop_down_icon.dart';
import 'package:acti_mobile/presentation/widgets/image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class MyCardEventWidget extends StatelessWidget {
  final OrganizedEventModel organizedEvent;
  final bool isPublicUser;
  final bool isCompletedEvent;
  const MyCardEventWidget({
    super.key,
    required this.organizedEvent,
    required this.isPublicUser,
    required this.isCompletedEvent,
  });

  @override
  Widget build(BuildContext context) {
    final reccuringDays = organizedEvent.isRecurring
        ? getWeeklyRepeatText(organizedEvent.dateStart)
        : null;
    final reccuringPartDays = reccuringDays?.split(' ');
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => isPublicUser
                    ? EventDetailScreen(
                        eventId: organizedEvent.id,
                      )
                    : EventDetailHomeScreen(
                        isCompletedEvent: isCompletedEvent,
                        organizedEventModel: organizedEvent,
                        eventId: organizedEvent.id,
                      )));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Opacity(
          opacity: isCompletedEvent ? 0.59 : 1,
          child: Card(
            elevation: 0.6,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SizedBox(
              height: 215,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                        child: organizedEvent.photos.isNotEmpty
                            ? Image.network(
                                organizedEvent.photos.first,
                                width: 130,
                                height: 215,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/image_default_event.png',
                                width: 130,
                                height: 215,
                                fit: BoxFit.cover,
                              ),
                      ),
                      if (isPublicUser == false)
                        Positioned(
                          bottom: 8,
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: 110,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: getStatusColor(organizedEvent.status),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              child: Center(
                                child: Text(
                                  getStatusText(organizedEvent.status),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 9.87,
                                      height: 1,
                                      fontFamily: 'Gilroy',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  organizedEvent.title,
                                  style: TextStyle(
                                      height: 1,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gilroy'),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Row(
                                children: [
                                  organizedEvent.restrictions.any(
                                          (restrict) => restrict == 'isAdults')
                                      ? SvgPicture.asset(
                                          'assets/icons/icon_adult.svg')
                                      : Container(),
                                  DropDownIcon(isPublicUser: isPublicUser, organizedEvent: organizedEvent),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          !organizedEvent.isRecurring
                              ? Row(
                                  children: [
                                    Text(
                                      custom_date.DateUtils.formatEventDate(
                                        organizedEvent.dateStart,
                                        organizedEvent.timeStart,
                                        organizedEvent.type == 'online',
                                      ),
                                      style: TextStyle(
                                          fontFamily: 'Gilroy',
                                          fontSize: 11.89,
                                          color: mainBlueColor,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              fontSize: 11.89,
                                              fontFamily: 'Gilroy',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700),
                                          children: [
                                            TextSpan(
                                              text: '${reccuringPartDays![0]} ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11.89,
                                                color: mainBlueColor,
                                                fontFamily: 'Gilroy',
                                              ),
                                            ),
                                            TextSpan(
                                              text: reccuringPartDays[1],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11.89,
                                                color: mainBlueColor,
                                                fontFamily: 'Gilroy',
                                              ),
                                            ),
                                            TextSpan(
                                                text: ' | ',
                                                style: TextStyle(
                                                    color: mainBlueColor)),
                                            TextSpan(
                                              text: custom_date.DateUtils
                                                  .formatEventTime(
                                                organizedEvent.dateStart,
                                                organizedEvent.timeStart,
                                                organizedEvent.timeEnd,
                                                organizedEvent.type == 'online',
                                              ),
                                              style: TextStyle(
                                                  fontFamily: 'Gilroy',
                                                  fontSize: 11.89,
                                                  color: mainBlueColor,
                                                  fontWeight: FontWeight.w700),
                                            )
                                          ],
                                        ),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(
                            height: 5,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                                height: 45,
                                child: Text(
                                  organizedEvent.description,
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          OverlappingAvatars(
                              imageUrls: organizedEvent.participants
                                  .where((user) => user.status == 'confirmed')
                                  .map((user) => user.user.photoUrl)
                                  .toList()),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SvgPicture.asset('assets/icons/icon_people.svg'),
                              SizedBox(width: 10),
                              Text(
                                organizedEvent.restrictions.any(
                                        (restrict) => restrict == 'isUnlimited')
                                    ? 'Неограниченно'
                                    : 'Свободно ${organizedEvent.freeSlots} из ${organizedEvent.slots} мест',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mainBlueColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              organizedEvent.price == 0
                                  ? RestrictionContainer(text: 'Бесплатное')
                                  : Container(),
                              SizedBox(
                                width: organizedEvent.price == 0 ? 10 : 0,
                              ),
                              organizedEvent.creator.isOrganization!
                                  ? RestrictionContainer(text: 'Компания')
                                  : Container()
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RestrictionContainer extends StatelessWidget {
  final String text;
  const RestrictionContainer({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25), color: mainBlueColor),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Text(
          text,
          style: TextStyle(
              color: Colors.white, fontFamily: 'Gilroy', fontSize: 9.87),
        ),
      ),
    );
  }
}
