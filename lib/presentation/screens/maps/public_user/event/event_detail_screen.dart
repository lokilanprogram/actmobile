import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/configs/date_utils.dart' as custom_date;
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/data/models/status_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/screen/public_user_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/map_picker/map_picker_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/widget/drop_down_icon.dart';
import 'package:acti_mobile/presentation/widgets/image_widget.dart';
import 'package:acti_mobile/presentation/widgets/popup_event_buttons.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool isLoading = false;
  bool isJoined = false;
  bool isBlocked = false;
  bool showParticipants = false;
  late OrganizedEventModel organizedEvent;
  ProfileModel? profileModel;
  int _currentPage = 0;
  late final PageController _pageController;
  late final bool isPublicUser;
  late final userId;
  late ScrollController _participantsScrollController;

  @override
  void initState() {
    _pageController = PageController();
    _participantsScrollController = ScrollController();
    _initAsync();
    initialize();
    super.initState();
  }

  Future<void> _initAsync() async {
    final storage = SecureStorageService();
    userId = await storage.getUserId();
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
  void dispose() {
    _pageController.dispose();
    _participantsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileJoinedState) {
          setState(() {
            organizedEvent = state.eventModel;
            isLoading = false;
            isJoined = true;
          });
          context.read<ProfileBloc>().add(
              ProfileGetPublicUserEvent(userId: organizedEvent.creatorId!));
          context.read<ProfileBloc>().add(ProfileGetListEventsEvent());
        }

        if (state is ProfileLeftState) {
          setState(() {
            organizedEvent = state.eventModel;
            isLoading = false;
            isJoined = false;
          });
          context.read<ProfileBloc>().add(
              ProfileGetPublicUserEvent(userId: organizedEvent.creatorId!));
          context.read<ProfileBloc>().add(ProfileGetListEventsEvent());
        }
        if (state is ProfileGotEventDetailState) {
          setState(() {
            profileModel = state.profileModel;
            isLoading = false;
            organizedEvent = state.eventModel;
            isPublicUser = userId != state.eventModel.creatorId;
            isJoined = state.eventModel.join_status == 'confirmed' ||
                state.eventModel.join_status == 'pending';
            isBlocked =
                state.eventModel.join_status == state.eventModel.freeSlots < 1;
          });
          // Scroll to the end after the list is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_participantsScrollController.hasClients) {
              _participantsScrollController.animateTo(
                _participantsScrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
          if (isBlocked) {
            showAlertOKDialog(context,
                'Мест нет, но вы можете написать организатору, возможно, он добавит вас в это мероприятие.');
          }
        }

        if (state is ProfileJoinedErrorState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorText)));
        }

        if (state is ProfileLeftErrorState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorText)));
        }

        if (state is ProfileGotEventDetailErrorState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? LoaderWidget()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        organizedEvent.photos.isNotEmpty
                            ? SizedBox(
                                height: 260,
                                child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: organizedEvent.photos.length,
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
                                          fit: BoxFit.cover, loadingBuilder:
                                              (BuildContext context,
                                                  Widget child,
                                                  ImageChunkEvent?
                                                      loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return SizedBox(
                                          height: 260,
                                          child: Center(
                                            child: CircularProgressIndicator(
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
                                    }),
                              )
                            : Image.asset(
                                'assets/images/image_default_event.png',
                                width: double.infinity,
                                height: 260,
                                fit: BoxFit.cover,
                              ),
                        Positioned(
                          top: 50,
                          right: 20,
                          child: DropDownIcon(
                            isPublicUser: isPublicUser,
                            organizedEvent: organizedEvent,
                          ),
                        ),

                        // Индикаторы
                        Positioned(
                          bottom: 35,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  organizedEvent.photos.length, (index) {
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
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
                        Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 20,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)),
                                  color: Colors.white),
                            )),
                      ],
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: showParticipants
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 5,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2.5),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showParticipants = false;
                                          });
                                        },
                                        icon: SvgPicture.asset(
                                            'assets/icons/icon_back_blue.svg')),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    organizedEvent.price == 0
                                        ? buildTag('Бесплатное')
                                        : Container(),
                                    const SizedBox(width: 8),
                                    buildTag('Компания'),
                                    Spacer(),
                                    SvgPicture.asset(
                                      'assets/icons/icon_adult.svg',
                                      width: 34,
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PublicUserScreen(
                                                    userId: organizedEvent
                                                        .creator.id!)));
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: organizedEvent
                                                    .creator.photoUrl !=
                                                null
                                            ? NetworkImage(organizedEvent
                                                .creator.photoUrl!)
                                            : AssetImage(
                                                'assets/images/image_profile.png'), // Заменить на нужную
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              organizedEvent.creator.name ??
                                                  '...',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.8,
                                                  fontFamily: 'Inter',
                                                  color: mainBlueColor)),
                                          Text('Организатор',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  letterSpacing: 0,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Gilroy')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 15),
                                  child: Divider(),
                                ),
                                Text(
                                  'Уже идут',
                                  style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Gilroy'),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  height: 100,
                                  child: ListView.separated(
                                    controller: _participantsScrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: organizedEvent.participants
                                        .where((user) =>
                                            user.status == 'confirmed')
                                        .length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(width: 15),
                                    itemBuilder: (context, index) {
                                      final participant = organizedEvent
                                          .participants
                                          .where((user) =>
                                              user.status == 'confirmed')
                                          .toList()[index];
                                      return Container(
                                        width: 80,
                                        margin: EdgeInsets.only(right: 10),
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              backgroundImage: participant
                                                          .user.photoUrl !=
                                                      null
                                                  ? NetworkImage(participant
                                                      .user.photoUrl!)
                                                  : AssetImage(
                                                          'assets/images/image_profile.png')
                                                      as ImageProvider,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              participant.user.name ??
                                                  'Не указано',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 9,
                                                fontFamily: 'Gilroy',
                                                color: Color.fromARGB(
                                                    255, 7, 7, 7),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 5,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2.5),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: SvgPicture.asset(
                                            'assets/icons/icon_back_blue.svg')),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    organizedEvent.price == 0
                                        ? buildTag('Бесплатное')
                                        : Container(),
                                    const SizedBox(width: 8),
                                    buildTag('Компания'),
                                    Spacer(),
                                    SvgPicture.asset(
                                      'assets/icons/icon_adult.svg',
                                      width: 34,
                                    )
                                  ],
                                ),

                                const SizedBox(height: 15),

                                // Автор и участники
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PublicUserScreen(
                                                        userId: organizedEvent
                                                            .creator.id!)));
                                      },
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage: organizedEvent
                                                        .creator.photoUrl !=
                                                    null
                                                ? NetworkImage(organizedEvent
                                                    .creator.photoUrl!)
                                                : AssetImage(
                                                    'assets/images/image_profile.png'), // Заменить на нужную
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  organizedEvent.creator.name ??
                                                      '...',
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
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showParticipants = !showParticipants;
                                        });
                                      },
                                      child: OverlappingAvatars(
                                          imageUrls: organizedEvent.participants
                                              .where((user) =>
                                                  user.status == 'confirmed')
                                              .map((user) => user.user.photoUrl)
                                              .toList()),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 15),
                                  child: Divider(),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Заголовок
                                    Text(
                                      organizedEvent.title,
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontFamily: 'Gilroy',
                                        height: 1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    if (!completedStatus
                                        .contains(organizedEvent.status)) ...[
                                      // Дата и время
                                      infoRow(
                                        organizedEvent,
                                        'assets/icons/icon_time.svg',
                                        false,
                                        'Дата и время',
                                        custom_date.DateUtils.formatEventTime(
                                            organizedEvent.dateStart,
                                            organizedEvent.timeStart,
                                            organizedEvent.timeEnd,
                                            organizedEvent.type == 'online'),
                                        trailing: custom_date.DateUtils
                                            .formatDuration(
                                                organizedEvent.timeStart,
                                                organizedEvent.timeEnd),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, bottom: 5),
                                        child: Divider(),
                                      ),

                                      // Место
                                      infoRow(
                                        organizedEvent,
                                        'assets/icons/icon_location.svg',
                                        true,
                                        'Место',
                                        organizedEvent.address,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, bottom: 5),
                                        child: Divider(),
                                      ),

                                      // Места
                                      infoRow(
                                        organizedEvent,
                                        'assets/icons/icon_people.svg',
                                        false,
                                        organizedEvent.restrictions != null
                                            ? (organizedEvent.restrictions.any(
                                                    (restrict) =>
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

                                      const SizedBox(height: 40),
                                    ],

                                    // Добавляем TabBar
                                    if (completedStatus
                                        .contains(organizedEvent.status))
                                      DefaultTabController(
                                        length: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TabBar(
                                              dividerColor: Colors.transparent,
                                              unselectedLabelStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Gilroy',
                                              ),
                                              labelStyle: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 66, 147, 239),
                                                fontFamily: 'Gilroy',
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              indicatorColor:
                                                  Colors.transparent,
                                              tabs: [
                                                Tab(text: 'Обзор'),
                                                Tab(text: 'Отзывы'),
                                              ],
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.4,
                                              child: TabBarView(
                                                children: [
                                                  // Вкладка "Обзор"
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Дата и время
                                                      infoRow(
                                                        organizedEvent,
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
                                                        trailing: custom_date
                                                                .DateUtils
                                                            .formatDuration(
                                                                organizedEvent
                                                                    .timeStart,
                                                                organizedEvent
                                                                    .timeEnd),
                                                      ),

                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                bottom: 5),
                                                        child: Divider(),
                                                      ),

                                                      // Место
                                                      infoRow(
                                                        organizedEvent,
                                                        'assets/icons/icon_location.svg',
                                                        true,
                                                        'Место',
                                                        organizedEvent.address,
                                                      ),

                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                bottom: 5),
                                                        child: Divider(),
                                                      ),

                                                      // Места
                                                      infoRow(
                                                        organizedEvent,
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
                                                            const EdgeInsets
                                                                .only(
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
                                                            fontFamily:
                                                                'Gilroy',
                                                            height: 1),
                                                      ),
                                                    ],
                                                  ),
                                                  // Вкладка "Отзывы"
                                                  Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
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
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(
                                  height: 59,
                                  width: double.infinity,
                                  child: !isPublicUser ||
                                          completedStatus
                                              .contains(organizedEvent.status)
                                      ? Container()
                                      : ElevatedButton(
                                          onPressed: () {
                                            if (profileModel!.isEmailVerified) {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              isJoined
                                                  ? context
                                                      .read<ProfileBloc>()
                                                      .add(ProfileLeaveEvent(
                                                          eventId:
                                                              organizedEvent
                                                                  .id))
                                                  : context
                                                      .read<ProfileBloc>()
                                                      .add(ProfileJoinEvent(
                                                          eventId:
                                                              organizedEvent
                                                                  .id));
                                            } else if (!profileModel!
                                                .isEmailVerified) {
                                              showAlertOKDialog(context, null,
                                                  isTitled: true,
                                                  title: 'Заполните профиль');
                                            } else if (organizedEvent
                                                    .freeSlots <
                                                1) {
                                              showAlertOKDialog(context, null,
                                                  isTitled: true,
                                                  title: 'Подтвердите почту');
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            backgroundColor: isBlocked
                                                ? mainBlueColor
                                                : (isJoined
                                                    ? Colors.red
                                                    : Color.fromRGBO(
                                                        98, 207, 102, 1)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: Text(
                                            isBlocked
                                                ? 'Написать организатору'
                                                : (isJoined
                                                    ? 'Не пойду'
                                                    : 'Пойду'),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.46,
                                                fontFamily: 'Gilroy'),
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                    ),
                  ],
                ),
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
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.46,
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget infoRow(OrganizedEventModel organizedEvent, String iconPath,
      bool isLocation, String title, String subtitle,
      {String? trailing}) {
    final recurringdays =
        'Проходит ${getWeeklyRepeatOnlyWeekText(organizedEvent.dateStart)}';
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
            Text(title,
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    fontSize: 17.8)),
          ],
        ),
        SizedBox(height: trailing != null ? 8 : 0),
        if (subtitle.isNotEmpty)
          GestureDetector(
            onTap: isLocation
                ? () {
                    if (organizedEvent.latitude != null &&
                        organizedEvent.longitude != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapPickerScreen(
                                    isCreated: false,
                                    position: Position(
                                        organizedEvent.longitude!,
                                        organizedEvent.latitude!),
                                    address: organizedEvent.address,
                                  )));
                    }
                  }
                : () {},
            child: trailing != null && organizedEvent.isRecurring
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                      fontFamily: 'Gilroy'),
                                ),
                                TextSpan(
                                  text: '${parts[1]} ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromRGBO(7, 7, 7, 1),
                                      fontFamily: 'Gilroy'),
                                ),
                                TextSpan(
                                  text: parts[2],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gilroy'),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Gilroy',
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Ближайшее: ${custom_date.DateUtils.formatEventDate(organizedEvent.dateStart, organizedEvent.timeStart, organizedEvent.type == 'online')}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromRGBO(7, 7, 7, 1),
                                  fontFamily: 'Gilroy'),
                            ),
                            TextSpan(
                              text: ' ',
                              style: TextStyle(
                                fontFamily: 'Gilroy',
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: custom_date.DateUtils.formatDuration(
                                  organizedEvent.timeStart,
                                  organizedEvent.timeEnd),
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
                      // if (trailing != null)
                      //   Text(trailing,
                      //       style: const TextStyle(color: Colors.grey)),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          subtitle,
                          maxLines: 2,
                          style: TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 16,
                              color: isLocation ? Colors.blue : Colors.black),
                        ),
                      ),
                      // if (trailing != null)
                      //   Text(trailing,
                      //       style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
          ),
      ],
    );
  }
}
