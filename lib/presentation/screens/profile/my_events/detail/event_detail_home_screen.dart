import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/widgets.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/create_event_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/map_picker/map_picker_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/requests/event_request_screen.dart';
import 'package:acti_mobile/presentation/widgets/error_widget.dart';
import 'package:acti_mobile/presentation/widgets/popup_event_buttons.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class EventDetailHomeScreen extends StatefulWidget {
  final String eventId;
  final bool isCompletedEvent;
  final OrganizedEventModel organizedEventModel;
  const EventDetailHomeScreen(
      {super.key,
      required this.isCompletedEvent,
      required this.eventId,
      required this.organizedEventModel});

  @override
  State<EventDetailHomeScreen> createState() => _EventDetailHomeScreenState();
}

class _EventDetailHomeScreenState extends State<EventDetailHomeScreen> {
  bool isLoading = false;
  bool isError = false;
  late OrganizedEventModel organizedEvent;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    setState(() {
      isLoading = true;
    });
    context
        .read<ProfileBloc>()
        .add(ProfileGetEventDetailEvent(eventId: widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileAcceptedUserOnActivityState) {
          initialize();
        }
        if (state is ProfileCanceledActivityState) {
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Мероприятие завершено')));
        }
        if (state is ProfileGotEventDetailState) {
          setState(() {
            isLoading = false;
            isError = false;
            organizedEvent = state.eventModel;
          });
        }

        if (state is ProfileCanceledActivityErrorState) {
          setState(() {
            isLoading = false;
            isError = true;
          });
        }

        if (state is ProfileGotEventDetailErrorState) {
          setState(() {
            isLoading = false;
            isError = true;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isError
            ? ErrorWidgetWithRetry(
                onRetry: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await initialize();
                },
              )
            : isLoading
                ? LoaderWidget()
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Stack(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height,
                                decoration: BoxDecoration(color: Colors.white),
                              ),
                              Stack(
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: organizedEvent.photos.isNotEmpty
                                        ? PageView.builder(
                                            controller: _pageController,
                                            itemCount:
                                                organizedEvent.photos.length,
                                            onPageChanged: (index) {
                                              setState(() {
                                                _currentPage = index;
                                              });
                                            },
                                            itemBuilder: (context, index) {
                                              return Image.network(
                                                organizedEvent.photos[index],
                                                width: double.infinity,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'assets/images/image_big_default_event.png',
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                      top: 50,
                                      right: 20,
                                      child: PopupMenuButton<int>(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        offset: const Offset(-10, 30),
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem<int>(
                                            value: 0,
                                            onTap: () async {
                                              final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CreateEventScreen(
                                                              organizedEventModel:
                                                                  organizedEvent)));
                                              if (result != null) {
                                                initialize();
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                    'assets/icons/icon_edit.svg'),
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
                                        child: const Icon(Icons.more_vert,
                                            color: Colors.white),
                                      )),

                                  // Индикаторы
                                  Positioned(
                                    bottom: 30,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                            organizedEvent.photos!.length,
                                            (index) {
                                          return AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 3),
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: index == _currentPage
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.5),
                                              shape: BoxShape.circle,
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 180,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25)),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              constraints: const BoxConstraints(
                                                  minWidth: 64),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: SvgPicture.asset(
                                                  'assets/icons/icon_back_blue.svg'),
                                            ),
                                            Row(
                                              children: [
                                                organizedEvent.price == 0
                                                    ? buildTag('Бесплатное')
                                                    : Container(),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                organizedEvent.creator
                                                            .isOrganization !=
                                                        null
                                                    ? (organizedEvent.creator
                                                            .isOrganization!
                                                        ? buildTag('Компания')
                                                        : Container())
                                                    : Container()
                                              ],
                                            ),
                                            Spacer(),
                                            organizedEvent.restrictions != null
                                                ? (organizedEvent.restrictions!
                                                        .any((rectrict) =>
                                                            rectrict ==
                                                            'isAdults')
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 30),
                                                        child: SvgPicture.asset(
                                                          'assets/icons/icon_adult.svg',
                                                          width: 34,
                                                        ),
                                                      )
                                                    : Container())
                                                : Container()
                                          ],
                                        ),

                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Text(
                                            capitalize(organizedEvent.title),
                                            style: TextStyle(
                                                fontFamily: 'Gilroy',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 23),
                                          ),
                                        ),

                                        const SizedBox(height: 15),

                                        // Автор и участники
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundImage: organizedEvent
                                                          .creator.photoUrl !=
                                                      null
                                                  ? NetworkImage(
                                                      '${organizedEvent.creator.photoUrl}')
                                                  : AssetImage(
                                                      'assets/images/image_profile.png'), // Заменить на нужную
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    organizedEvent.creator.name,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17.8,
                                                        fontFamily: 'Inter',
                                                        color: mainBlueColor)),
                                                Text('Организатор',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Gilroy')),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Center(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          EventRequestScreen(
                                                            eventId:
                                                                organizedEvent
                                                                    .id,
                                                            participants:
                                                                organizedEvent
                                                                    .participants,
                                                          )));
                                            },
                                            child: Material(
                                              color: Colors.white,
                                              elevation: 1.2,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: SizedBox(
                                                height: 59,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                      widget.isCompletedEvent
                                                          ? 'Участники'
                                                          : 'Заявки',
                                                      style: TextStyle(
                                                          color: mainBlueColor,
                                                          fontFamily: 'Inter',
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 15,
                                                    ),
                                                    SvgPicture.asset(
                                                        'assets/icons/icon_next_blue.svg')
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Text(
                                          'Обзор',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontFamily: 'Gilroy',
                                            height: 1,
                                            color: mainBlueColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),

                                            // Дата и время
                                            organizedEvent.isRecurring
                                                ? infoRepeatedRow(
                                                    'assets/icons/icon_time.svg',
                                                    false,
                                                    'Проходит ' +
                                                        getWeeklyRepeatOnlyWeekText(
                                                            organizedEvent
                                                                .dateStart),
                                                    organizedEvent.dateStart,
                                                    '${organizedEvent.timeStart.substring(0, 5)}–${organizedEvent.timeEnd.substring(0, 5)}',
                                                    trailing: formatDuration(
                                                        organizedEvent
                                                            .timeStart,
                                                        organizedEvent.timeEnd),
                                                  )
                                                : infoRow(
                                                    'assets/icons/icon_time.svg',
                                                    false,
                                                    'Дата и время',
                                                    '${DateFormat('dd.MM.yyyy').format(organizedEvent.dateStart)} | ${organizedEvent.timeStart.substring(0, 5)}–${organizedEvent.timeEnd.substring(0, 5)}',
                                                    trailing: formatDuration(
                                                        organizedEvent
                                                            .timeStart,
                                                        organizedEvent.timeEnd),
                                                  ),
                                            SizedBox(
                                                height:
                                                    organizedEvent.address != ''
                                                        ? 20
                                                        : 0),

                                            organizedEvent.address != ''
                                                ? infoRow(
                                                    'assets/icons/icon_location.svg',
                                                    true,
                                                    'Место',
                                                    organizedEvent.address,
                                                  )
                                                : Container(),

                                            const SizedBox(height: 20),

                                            // Места
                                            infoRow(
                                              'assets/icons/icon_people.svg',
                                              false,
                                              organizedEvent.restrictions !=
                                                      null
                                                  ? (organizedEvent
                                                          .restrictions!
                                                          .any((restrict) =>
                                                              restrict ==
                                                              'isUnlimited')
                                                      ? 'Неограниченно'
                                                      : 'Свободно ${organizedEvent.freeSlots} из ${organizedEvent.slots} мест')
                                                  : 'Свободно ${organizedEvent.freeSlots} из ${organizedEvent.slots} мест',
                                              '',
                                            ),

                                            const SizedBox(height: 20),
                                            // Описание
                                            Text(
                                              organizedEvent.description,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Gilroy',
                                                  height: 1),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      widget.isCompletedEvent
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 60, left: 30, right: 30),
                              child: buildCancelWidget(),
                            ),
                    ],
                  ),
      ),
    );
  }

  SizedBox buildCancelWidget() {
    return SizedBox(
      height: 59,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          organizedEvent.isRecurring
              ? showCancelActivityDialog(
                  context,
                  'Вы хотите отменить одно мероприятие или всю серию?',
                  'Ближайшее',
                  'Все',
                  () {
                    setState(() {
                      isLoading = true;
                    });
                    context.read<ProfileBloc>().add(ProfileCancelActivityEvent(
                        eventId: organizedEvent.id, isRecurring: true));
                  },
                  () {
                    setState(() {
                      isLoading = true;
                    });
                    context.read<ProfileBloc>().add(ProfileCancelActivityEvent(
                        eventId: organizedEvent.id, isRecurring: false));
                  },
                )
              : showCancelActivityDialog(
                  context, 'Вы хотите отменить мероприятие?', 'Да', 'Нет', () {
                  setState(() {
                    isLoading = true;
                  });
                  context.read<ProfileBloc>().add(ProfileCancelActivityEvent(
                      eventId: organizedEvent.id, isRecurring: true));
                }, () {});
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Отменить мероприятие',
          style: TextStyle(
              color: Colors.white, fontSize: 16.46, fontFamily: 'Gilroy'),
        ),
      ),
    );
  }

  Widget buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 12.46, fontFamily: 'Gilroy'),
      ),
    );
  }

  Widget infoRow(
      String iconPath, bool isLocation, String title, String subtitle,
      {String? trailing}) {
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
            Text(title,
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    fontSize: 17.8)),
          ],
        ),
        if (subtitle.isNotEmpty)
          SizedBox(
            height: 8,
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
          child: Row(
            children: [
              Text(
                subtitle,
                style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 16,
                    color: isLocation ? Colors.blue : Colors.black),
              ),
              SizedBox(
                width: 10,
              ),
              if (trailing != null)
                Text(trailing, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
