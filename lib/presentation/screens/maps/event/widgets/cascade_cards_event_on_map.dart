import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/widgets.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/widget/my_events_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class CascadeCardsEventOnMap extends StatelessWidget {
  final List<OrganizedEventModel> organizedEvents;
  final String profileId;

  const CascadeCardsEventOnMap(
      {super.key, required this.organizedEvents, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 20, bottom: 0),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SvgPicture.asset('assets/icons/icon_divider_sheet.svg'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: organizedEvents.length,
                itemBuilder: (context, index) {
                  final event = organizedEvents[index];
                  return MyCardEventWidget(
                    organizedEvent: event,
                    isPublicUser: event.creatorId != profileId,
                    isCompletedEvent: false,
                  );
                },
              ),
            ),
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
