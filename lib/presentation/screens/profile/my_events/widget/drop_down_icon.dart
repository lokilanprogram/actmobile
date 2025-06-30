import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/create_event_screen.dart';
import 'package:acti_mobile/presentation/widgets/report_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:acti_mobile/configs/deeplink_service.dart';

class DropDownIcon extends StatelessWidget {
  const DropDownIcon({
    super.key,
    required this.isPublicUser,
    required this.organizedEvent,
  });

  final bool isPublicUser;
  final OrganizedEventModel organizedEvent;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      offset: const Offset(-20, 5),
      itemBuilder: (BuildContext context) => isPublicUser
          ? [
              PopupMenuItem<int>(
                value: 0,
                onTap: () async {
                  final deeplinkService = DeeplinkService();
                  final eventLink =
                      deeplinkService.generateEventLink(organizedEvent.id);
                  final url = organizedEvent.photos.isNotEmpty
                      ? organizedEvent.photos.first
                      : '';
                  final text = 'Посмотрите это событие в Acti: $eventLink';
                  await Future.delayed(Duration.zero, () {
                    Share.share(text);
                  });
                },
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/icon_share.svg'),
                    SizedBox(width: 10),
                    Text(
                      "Поделиться",
                      style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                onTap: () => _showReportSheet(context, organizedEvent.id),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/icon_block.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.red,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Пожаловаться",
                      style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.red),
                    ),
                  ],
                ),
              ),
            ]
          : [
              PopupMenuItem<int>(
                value: 0,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateEventScreen(
                              organizedEventModel: organizedEvent)));
                },
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/icon_edit.svg'),
                    SizedBox(width: 10),
                    Text(
                      "Редактировать",
                      style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 12.93,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
      child: const Icon(Icons.more_vert, color: Colors.black),
    );
  }
}

void _showReportSheet(BuildContext context, String eventId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (_) => ReportEventSheetWidget(eventId: eventId),
  );
}
