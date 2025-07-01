import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/configs/date_utils.dart' as custom_date;
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/reviews_model.dart';
import 'package:acti_mobile/data/models/status_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/events/screens/events_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/widgets.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/create_event_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/map_picker/map_picker_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/get/my_events_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/requests/event_request_screen.dart';
import 'package:acti_mobile/presentation/widgets/error_widget.dart';
import 'package:acti_mobile/presentation/widgets/gradient_text.dart';
import 'package:acti_mobile/presentation/widgets/popup_event_buttons.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class EventDetailHomeScreen extends StatefulWidget {
  final String eventId;
  final bool? isCompletedEvent;
  final OrganizedEventModel? organizedEventModel;
  const EventDetailHomeScreen(
      {super.key,
      this.isCompletedEvent,
      required this.eventId,
      this.organizedEventModel});

  @override
  State<EventDetailHomeScreen> createState() => _EventDetailHomeScreenState();
}

class _EventDetailHomeScreenState extends State<EventDetailHomeScreen> {
  bool isLoading = false;
  bool isError = false;
  late OrganizedEventModel organizedEvent;
  final PageController _pageController = PageController();
  late ReviewsModel rewiewsModel;
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
            rewiewsModel = state.rewiews;
          });
        }

        if (state is ProfileCanceledActivityErrorState) {
          setState(() {
            isLoading = false;
            isError = true;
          });
        }

        if (state is ProfileGotEventDetailErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => MyEventsScreen()));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: isError
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
                  : Stack(children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Stack(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height,
                              decoration: BoxDecoration(color: Colors.white),
                            ),
                            Stack(
                              children: [
                                SizedBox(
                                  height: 260,
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
                                                height: 260,
                                                fit: BoxFit.cover,
                                                loadingBuilder:
                                                    (BuildContext context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return SizedBox(
                                                height: 260,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: mainBlueColor,
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            });
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
                                        borderRadius: BorderRadius.circular(15),
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
                                  bottom: 35,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                          organizedEvent.photos.length,
                                          (index) {
                                        return AnimatedContainer(
                                          duration: Duration(milliseconds: 200),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: index == _currentPage
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 240,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25)),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                              alignment: Alignment.centerLeft,
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: SvgPicture.asset(
                                                'assets/icons/icon_back_blue.svg',
                                                alignment: Alignment.centerLeft,
                                              )),
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
                                              Text(organizedEvent.creator.name,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17.8,
                                                      fontFamily: 'Inter',
                                                      color: mainBlueColor)),
                                              Text('Организатор',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      letterSpacing: 0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'Gilroy')),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, bottom: 5),
                                        child: Divider(),
                                      ),
                                      Text(
                                        capitalize(organizedEvent.title),
                                        style: TextStyle(
                                            fontFamily: 'Gilroy',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 23),
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        alignment: WrapAlignment.start,
                                        runSpacing: 5,
                                        spacing: 10,
                                        children: [
                                          buildStatus(organizedEvent.status),
                                          organizedEvent.price == 0
                                              ? buildTag('Бесплатное')
                                              : buildTag(organizedEvent.price
                                                      .toString() +
                                                  " ₽"),
                                          if (organizedEvent
                                                  .creator.isOrganization ??
                                              false)
                                            buildTag('Компания'),
                                          if (organizedEvent.type == 'online')
                                            buildTag('Онлайн'),
                                          if (organizedEvent.restrictions
                                              .contains("withKids"))
                                            buildTag('Можно с детьми'),
                                          if (organizedEvent.restrictions
                                              .contains("withAnimals"))
                                            buildTag('Можно с животными'),
                                          if (organizedEvent.restrictions
                                              .contains("isKidsNotAllowed"))
                                            buildTag('18+'),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Center(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        EventRequestScreen(
                                                          eventId:
                                                              organizedEvent.id,
                                                          completedStatus:
                                                              completedStatus.contains(
                                                                  organizedEvent
                                                                      .status),
                                                          participants:
                                                              organizedEvent
                                                                  .participants,
                                                        )));
                                          },
                                          child: Material(
                                            color: Colors.white,
                                            elevation: 1.2,
                                            borderRadius:
                                                BorderRadius.circular(16),
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
                                                    completedStatus.contains(
                                                            organizedEvent
                                                                .status)
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
                                      if (organizedEvent.rejectionReason !=
                                              '' &&
                                          organizedEvent.status ==
                                              "editing") ...[
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Причина редактирования:',
                                          style: TextStyle(
                                            fontSize: 17.8,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                            color: mainBlueColor,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          organizedEvent.rejectionReason ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                      if (organizedEvent.rejectionReason !=
                                              '' &&
                                          organizedEvent.status ==
                                              "rejected") ...[
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Причина отклонения:',
                                          style: TextStyle(
                                            fontSize: 17.8,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                            color: Color.fromARGB(255, 216, 0, 0),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          organizedEvent.rejectionReason ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                      // SizedBox(
                                      //   height: 16,
                                      // ),
                                      if (organizedEvent.status !=
                                          "completed") ...[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 18),

                                            // Дата и время
                                            organizedEvent.isRecurring
                                                ? infoRepeatedRow(
                                                    'assets/icons/icon_time.svg',
                                                    false,
                                                    'Проходит ${getWeeklyRepeatOnlyWeekText(organizedEvent.dateStart)}',
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
                                                    custom_date.DateUtils
                                                        .formatEventTime(
                                                            organizedEvent
                                                                .dateStart,
                                                            organizedEvent
                                                                .timeStart,
                                                            organizedEvent
                                                                .timeEnd,
                                                            organizedEvent
                                                                    .type ==
                                                                'online'),
                                                    trailing: formatDuration(
                                                        organizedEvent
                                                            .timeStart,
                                                        organizedEvent.timeEnd),
                                                  ),
                                            organizedEvent.address != ''
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5, bottom: 5),
                                                    child: Divider(),
                                                  )
                                                : Container(),

                                            organizedEvent.address != ''
                                                ? infoRow(
                                                    'assets/icons/icon_location.svg',
                                                    true,
                                                    'Место',
                                                    organizedEvent.address,
                                                  )
                                                : Container(),

                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Divider(),
                                            ),

                                            // Места
                                            infoRow(
                                              'assets/icons/icon_people.svg',
                                              false,
                                              organizedEvent.restrictions !=
                                                      null
                                                  ? (organizedEvent.restrictions
                                                          .any((restrict) =>
                                                              restrict ==
                                                              'isUnlimited')
                                                      ? 'Неограниченно'
                                                      : 'Свободно ${organizedEvent.freeSlots} из ${organizedEvent.slots} мест')
                                                  : 'Свободно ${organizedEvent.freeSlots} из ${organizedEvent.slots} мест',
                                              '',
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Divider(),
                                            ),
                                            // Описание
                                            Text(
                                              organizedEvent.description,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Gilroy',
                                                  height: 1),
                                            ),
                                            SizedBox(height: 90),
                                          ],
                                        ),
                                      ],
                                      if (organizedEvent.status ==
                                          "completed") ...[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _currentPage = 0;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        right: 20,
                                                        top: 10,
                                                        bottom: 0),
                                                    child: Text(
                                                      'Обзор',
                                                      style: TextStyle(
                                                        color: _currentPage == 0
                                                            ? mainBlueColor
                                                            : Colors.black,
                                                        fontSize: 22,
                                                        fontWeight:
                                                            _currentPage == 0
                                                                ? FontWeight
                                                                    .w600
                                                                : FontWeight
                                                                    .w400,
                                                        fontFamily: 'Gilroy',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _currentPage = 1;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        right: 20,
                                                        top: 10,
                                                        bottom: 0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Отзывы',
                                                          style: TextStyle(
                                                            color: _currentPage ==
                                                                    1
                                                                ? mainBlueColor
                                                                : Colors.black,
                                                            fontSize: 22,
                                                            fontWeight:
                                                                _currentPage ==
                                                                        1
                                                                    ? FontWeight
                                                                        .w600
                                                                    : FontWeight
                                                                        .w400,
                                                            fontFamily:
                                                                'Gilroy',
                                                          ),
                                                        ),
                                                        SizedBox(width: 5),
                                                        if (rewiewsModel
                                                                    .reviews !=
                                                                null &&
                                                            rewiewsModel
                                                                    .reviews !=
                                                                [])
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 2,
                                                            ),
                                                            constraints:
                                                                BoxConstraints(
                                                                    maxHeight:
                                                                        18,
                                                                    minWidth:
                                                                        18),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  mainBlueColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                rewiewsModel
                                                                    .reviews
                                                                    .length
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: 9,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontFamily:
                                                                        'Inter'),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IndexedStack(
                                              index: _currentPage,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 16),

                                                    // Дата и время
                                                    organizedEvent.isRecurring
                                                        ? infoRepeatedRow(
                                                            'assets/icons/icon_time.svg',
                                                            false,
                                                            'Проходит ${getWeeklyRepeatOnlyWeekText(organizedEvent.dateStart)}',
                                                            organizedEvent
                                                                .dateStart,
                                                            '${organizedEvent.timeStart.substring(0, 5)}–${organizedEvent.timeEnd.substring(0, 5)}',
                                                            trailing: formatDuration(
                                                                organizedEvent
                                                                    .timeStart,
                                                                organizedEvent
                                                                    .timeEnd),
                                                          )
                                                        : infoRow(
                                                            'assets/icons/icon_time.svg',
                                                            false,
                                                            'Дата и время',
                                                            custom_date.DateUtils.formatEventTime(
                                                                organizedEvent
                                                                    .dateStart,
                                                                organizedEvent
                                                                    .timeStart,
                                                                organizedEvent
                                                                    .timeEnd,
                                                                organizedEvent
                                                                        .type ==
                                                                    'online'),
                                                            trailing: formatDuration(
                                                                organizedEvent
                                                                    .timeStart,
                                                                organizedEvent
                                                                    .timeEnd),
                                                          ),

                                                    organizedEvent.address !=
                                                                '' &&
                                                            organizedEvent
                                                                    .address !=
                                                                null
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5,
                                                                    bottom: 5),
                                                            child: Divider(),
                                                          )
                                                        : Container(),

                                                    organizedEvent.address != ''
                                                        ? infoRow(
                                                            'assets/icons/icon_location.svg',
                                                            true,
                                                            'Место',
                                                            organizedEvent
                                                                .address,
                                                          )
                                                        : Container(),

                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5,
                                                              bottom: 5),
                                                      child: Divider(),
                                                    ),

                                                    // Места
                                                    infoRow(
                                                      'assets/icons/icon_people.svg',
                                                      false,
                                                      organizedEvent
                                                                  .restrictions !=
                                                              null
                                                          ? (organizedEvent
                                                                  .restrictions
                                                                  .any((restrict) =>
                                                                      restrict ==
                                                                      'isUnlimited')
                                                              ? 'Неограниченно'
                                                              : 'Свободно ${organizedEvent.freeSlots} из ${organizedEvent.slots} мест')
                                                          : 'Свободно ${organizedEvent.freeSlots} из ${organizedEvent.slots} мест',
                                                      '',
                                                    ),

                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5,
                                                              bottom: 5),
                                                      child: Divider(),
                                                    ),
                                                    // Описание
                                                    Text(
                                                      organizedEvent
                                                          .description,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: 'Gilroy',
                                                          height: 1),
                                                    ),
                                                  ],
                                                ),
                                                // Вкладка "Отзывы"
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      if (rewiewsModel
                                                                  .reviews ==
                                                              null ||
                                                          rewiewsModel
                                                                  .reviews ==
                                                              []) ...[
                                                        Icon(
                                                          Icons
                                                              .chat_bubble_outline,
                                                          size: 48,
                                                          color: Colors.grey,
                                                        ),
                                                        SizedBox(height: 16),
                                                        Text(
                                                          'Пока нет отзывов',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey,
                                                            fontFamily:
                                                                'Gilroy',
                                                          ),
                                                        ),
                                                      ],
                                                      if (rewiewsModel
                                                                  .reviews !=
                                                              null &&
                                                          rewiewsModel
                                                                  .reviews !=
                                                              []) ...[
                                                        ListView.separated(
                                                          shrinkWrap: true,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    CircleAvatar(
                                                                      radius:
                                                                          21,
                                                                      backgroundImage: rewiewsModel.reviews[index].user.photoUrl != "" &&
                                                                              rewiewsModel.reviews[index].user.photoUrl !=
                                                                                  null
                                                                          ? NetworkImage(rewiewsModel
                                                                              .reviews[index]
                                                                              .user
                                                                              .photoUrl!)
                                                                          : AssetImage('assets/images/image_profile.png'),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          rewiewsModel
                                                                              .reviews[index]
                                                                              .user
                                                                              .name,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                              'assets/icons/icon_star.svg',
                                                                              width: 23,
                                                                              height: 23,
                                                                            ),
                                                                            SizedBox(width: 4),
                                                                            GradientText(
                                                                              rewiewsModel.reviews[index].rating.toInt().toString(),
                                                                              gradient: LinearGradient(
                                                                                colors: [
                                                                                  Color.fromRGBO(23, 132, 255, 1),
                                                                                  Color.fromRGBO(42, 244, 72, 1),
                                                                                ],
                                                                              ),
                                                                              style: TextStyle(
                                                                                fontFamily: 'Inter',
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                Text(
                                                                  rewiewsModel
                                                                      .reviews[
                                                                          index]
                                                                      .comment,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Gilroy',
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                )
                                                              ],
                                                            );
                                                          },
                                                          itemCount:
                                                              rewiewsModel
                                                                  .reviews
                                                                  .length,
                                                          separatorBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 20,
                                                                      right: 20,
                                                                      top: 5),
                                                              child: Divider(),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      completedStatus.contains(organizedEvent.status)
                          ? Container()
                          : Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 0, 30, 30),
                                child: buildCancelWidget(),
                              ),
                            ),
                    ]),
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
                  'Одно',
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

  Widget buildStatus(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: getStatusColor(status), width: 1),
        borderRadius: BorderRadius.circular(76),
      ),
      child: Text(
        getStatusText(status),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: getStatusColor(status),
          fontSize: 12.46,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
        ),
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
                    color: mainBlueColor,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    fontSize: 17.8)),
          ],
        ),
        if (subtitle.isNotEmpty)
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
            child: Text(
              subtitle,
              style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  color: isLocation ? mainBlueColor : Colors.black),
            ),
          ),
      ],
    );
  }

  Widget infoRepeatedRow(String iconPath, bool isLocation, String title,
      DateTime date, String time,
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
            Text('Дата и время',
                style: const TextStyle(
                    color: mainBlueColor,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    fontSize: 17.8)),
          ],
        ),
        SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: _buildTitleSpans(title),
          ),
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Gilroy',
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: 'Ближайшее: ' +
                    custom_date.DateUtils.formatEventDate(
                      date,
                      time,
                      organizedEvent.type == 'online',
                    ),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Color.fromRGBO(7, 7, 7, 1),
                  fontFamily: 'Gilroy',
                ),
              ),
              if (trailing != null)
                TextSpan(
                  text: ' $trailing',
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
}

List<InlineSpan> _buildTitleSpans(String title) {
  final words = title.split(' ');
  if (words.isEmpty) return [];

  final lastWord = words.removeLast();
  final baseStyle = const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    fontSize: 15,
  );

  return [
    TextSpan(
      text: words.join(' ') + (words.isNotEmpty ? ' ' : ''),
      style: baseStyle,
    ),
    TextSpan(
      text: lastWord,
      style: baseStyle.copyWith(fontWeight: FontWeight.w600),
    ),
  ];
}
