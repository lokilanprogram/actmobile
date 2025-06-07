import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/map_picker/map_picker_screen.dart';
import 'package:acti_mobile/presentation/widgets/image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

Widget buildHeader(String title) => Text(
      title,
      style: TextStyle(
          height: 1,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Gilroy'),
    );

Widget buildInfoRow(
    OrganizedEventModel organizedEvent,
    BuildContext context,
    IconData icon,
    String dateTimeText,
    String startTime,
    String timeEnd,
    String address) {
  final recurringdays =
      'Проходит ${getWeeklyRepeatOnlyWeekText(organizedEvent.dateStart)}';
  final parts = recurringdays.split(' ');
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset('assets/icons/icon_time.svg'),
            SizedBox(
              width: 10,
            ),
            Text(
              'Дата и время',
              style: TextStyle(
                  color: mainBlueColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  fontSize: 17.8),
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
        organizedEvent.isRecurring == false
            ? Row(
                children: [
                  Text(
                    dateTimeText,
                    style: TextStyle(fontFamily: 'Gilroy', fontSize: 16),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    formatDuration(startTime, timeEnd),
                    style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 16,
                        color: Colors.grey),
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Gilroy',
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: '${parts[0]} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color.fromRGBO(7, 7, 7, 1),
                                fontFamily: 'Gilroy',
                              ),
                            ),
                            TextSpan(
                              text: '${parts[1]} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color.fromRGBO(7, 7, 7, 1),
                                fontFamily: 'Gilroy',
                              ),
                            ),
                            TextSpan(
                              text: parts[2],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Gilroy',
                              ),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: RichText(
                      maxLines: 2,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Gilroy',
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'Ближайшее: ${DateFormat('dd.MM.yyyy').format(organizedEvent.dateStart)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Color.fromRGBO(7, 7, 7, 1),
                              fontFamily: 'Gilroy',
                            ),
                          ),
                          TextSpan(
                            text:
                                ' | ${organizedEvent.timeStart.substring(0, 5)}–${organizedEvent.timeEnd.substring(0, 5)} ',
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: formatDuration(startTime, timeEnd),
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
          child: Divider(
            thickness: 1,
          ),
        ),
        GestureDetector(
          onTap: () {
            if (organizedEvent.latitude != null &&
                organizedEvent.longitude != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPickerScreen(
                            isCreated: false,
                            position: Position(organizedEvent.longitude!,
                                organizedEvent.latitude!),
                            address: organizedEvent.address,
                          )));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/icons/icon_location.svg'),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Место',
                    style: TextStyle(
                        color: mainBlueColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        fontSize: 17.8),
                  )
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      address,
                      maxLines: 2,
                      style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 15,
                          color: mainBlueColor,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    ),
  );
}

Widget buildSpotsIndicator(
        bool isUnlimited, int freeSlots, int slots, List<String?> imageUrl) =>
    Row(
      children: [
        SvgPicture.asset('assets/icons/icon_people.svg'),
        SizedBox(width: 10),
        Text(
          isUnlimited && slots == 0
              ? 'Неограниченно'
              : 'Свободно $freeSlots из $slots мест',
          style: TextStyle(
            fontSize: 17.8,
            color: mainBlueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
        Expanded(child: OverlappingAvatars(imageUrls: imageUrl))
      ],
    );

Widget infoRepeatedRow(
  String iconPath,
  bool isLocation,
  String recurringdays,
  DateTime dateStart,
  String time, {
  String? trailing,
}) {
  final parts = recurringdays.split(' ');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: SvgPicture.asset(iconPath),
          ),
          const SizedBox(width: 10),
          Text(
            'Дата и время',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              fontSize: 17.8,
            ),
          ),
        ],
      ),
      const SizedBox(width: 10),
      Row(
        children: [
          Expanded(
            // 👈 Эта часть тоже оборачивается
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Gilroy',
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: '${parts[0]} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Color.fromRGBO(7, 7, 7, 1),
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  TextSpan(
                    text: '${parts[1]} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Color.fromRGBO(7, 7, 7, 1),
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  TextSpan(
                    text: parts[2],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Gilroy',
                    ),
                  ),
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
      RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Gilroy',
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: 'Ближайшее: ${DateFormat('dd.MM.yyyy').format(dateStart)}',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Color.fromRGBO(7, 7, 7, 1),
                fontFamily: 'Gilroy',
              ),
            ),
            TextSpan(
              text: '  |  $time   ',
              style: TextStyle(
                fontFamily: 'Gilroy',
                color: isLocation ? Colors.blue : Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            TextSpan(
              text: trailing,
              style: TextStyle(
                fontFamily: 'Gilroy',
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        overflow: TextOverflow.fade,
      ),
    ],
  );
}
