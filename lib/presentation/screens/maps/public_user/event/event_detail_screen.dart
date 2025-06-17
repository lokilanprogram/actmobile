import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/configs/date_utils.dart' as custom_date;
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/data/models/reviews_model.dart';
import 'package:acti_mobile/data/models/status_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/screen/public_user_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/map_picker/map_picker_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/widget/drop_down_icon.dart';
import 'package:acti_mobile/presentation/widgets/add_reviews.dart';
import 'package:acti_mobile/presentation/widgets/gradient_text.dart';
import 'package:acti_mobile/presentation/widgets/image_widget.dart';
import 'package:acti_mobile/presentation/widgets/popup_event_buttons.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();
  late ReviewsModel rewiewsModel;
  bool isOpenAddReviews = false;

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
    _dateFocusNode.dispose();
    _locationFocusNode.dispose();
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
            rewiewsModel = state.rewiews;
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
          if (state.eventModel.status == 'completed' &&
              isOpenAddReviews == false) {
            if (!rewiewsModel.reviews
                .any((review) => review.user.id == userId)) {
              showAddReviewsBottomSheet(context, userId, state.eventModel);
            }
          }
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
            : Stack(
                children: [
                  SingleChildScrollView(
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
                                          return CachedNetworkImage(
                                            imageUrl:
                                                organizedEvent.photos[index],
                                            width: double.infinity,
                                            height: 260,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              height: 260,
                                              color: Colors.grey[300],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: mainBlueColor,
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              height: 260,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.error),
                                            ),
                                          );
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
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(2.5),
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
                                          width: 5,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PublicUserScreen(
                                                            userId:
                                                                organizedEvent
                                                                    .creator
                                                                    .id!)));
                                          },
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl: organizedEvent
                                                            .creator.photoUrl ??
                                                        '',
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                      color: Colors.grey[300],
                                                      child: Icon(Icons.person,
                                                          color:
                                                              Colors.grey[400]),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Container(
                                                      color: Colors.grey[300],
                                                      child: Icon(Icons.person,
                                                          color:
                                                              Colors.grey[400]),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      organizedEvent
                                                              .creator.name ??
                                                          '...',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 17.8,
                                                          fontFamily: 'Inter',
                                                          color:
                                                              mainBlueColor)),
                                                  Text(
                                                    'Организатор',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        letterSpacing: 0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: 'Gilroy'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    //const SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10),
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
                                        controller:
                                            _participantsScrollController,
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
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl: participant
                                                              .user.photoUrl ??
                                                          '',
                                                      width: 60,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        color: Colors.grey[300],
                                                        child: Icon(
                                                            Icons.person,
                                                            color: Colors
                                                                .grey[400]),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Container(
                                                        color: Colors.grey[300],
                                                        child: Icon(
                                                            Icons.person,
                                                            color: Colors
                                                                .grey[400]),
                                                      ),
                                                    ),
                                                  ),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(2.5),
                                        ),
                                      ),
                                    ),
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
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PublicUserScreen(
                                                            userId:
                                                                organizedEvent
                                                                    .creator
                                                                    .id!)));
                                          },
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl: organizedEvent
                                                            .creator.photoUrl ??
                                                        '',
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                      color: Colors.grey[300],
                                                      child: Icon(Icons.person,
                                                          color:
                                                              Colors.grey[400]),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Container(
                                                      color: Colors.grey[300],
                                                      child: Icon(Icons.person,
                                                          color:
                                                              Colors.grey[400]),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      organizedEvent
                                                              .creator.name ??
                                                          '...',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 17.8,
                                                          fontFamily: 'Inter',
                                                          color:
                                                              mainBlueColor)),
                                                  Text(
                                                    'Организатор',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        letterSpacing: 0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: 'Gilroy'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showParticipants =
                                                  !showParticipants;
                                            });
                                          },
                                          child: OverlappingAvatars(
                                              imageUrls: organizedEvent
                                                  .participants
                                                  .where((user) =>
                                                      user.status ==
                                                      'confirmed')
                                                  .map((user) =>
                                                      user.user.photoUrl)
                                                  .toList()),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, bottom: 5),
                                      child: Divider(),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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

                                        const SizedBox(height: 10),

                                        Wrap(
                                          alignment: WrapAlignment.start,
                                          runSpacing: 5,
                                          spacing: 10,
                                          children: [
                                            organizedEvent.price == 0
                                                ? buildTag('Бесплатное')
                                                : buildTag(organizedEvent.price
                                                        .toString() +
                                                    " ₽"),
                                            if (organizedEvent.status ==
                                                'completed')
                                              buildTag('Завершено'),
                                            if (organizedEvent.restrictions
                                                .contains("withKids"))
                                              buildTag('Можно с детьми'),
                                            if (organizedEvent
                                                    .creator.isOrganization ??
                                                false)
                                              buildTag('Компания'),
                                            if (organizedEvent.type == 'online')
                                              buildTag('Онлайн'),
                                            if (organizedEvent.restrictions
                                                .contains("withAnimals"))
                                              buildTag('Можно с животными'),
                                            if (organizedEvent.restrictions
                                                .contains("isKidsNotAllowed"))
                                              buildTag('18+'),
                                          ],
                                        ),
                                        SizedBox(height: 10),

                                        if (!completedStatus.contains(
                                            organizedEvent.status)) ...[
                                          // Дата и время
                                          infoRow(
                                            organizedEvent,
                                            'assets/icons/icon_time.svg',
                                            false,
                                            'Дата и время',
                                            custom_date.DateUtils
                                                .formatEventTime(
                                                    organizedEvent.dateStart,
                                                    organizedEvent.timeStart,
                                                    organizedEvent.timeEnd,
                                                    organizedEvent.type ==
                                                        'online'),
                                            trailing: formatDuration(
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

                                          const SizedBox(height: 90),
                                        ],

                                        // Добавляем TabBar
                                        if (completedStatus
                                            .contains(organizedEvent.status))
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
                                                          bottom: 10),
                                                      child: Text(
                                                        'Обзор',
                                                        style: TextStyle(
                                                          color: _currentPage ==
                                                                  0
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
                                                          bottom: 10),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Отзывы',
                                                            style: TextStyle(
                                                              color: _currentPage ==
                                                                      1
                                                                  ? mainBlueColor
                                                                  : Colors
                                                                      .black,
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
                                                                      fontSize:
                                                                          9,
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
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.5,
                                                child: IndexedStack(
                                                  index: _currentPage,
                                                  children: [
                                                    // Вкладка "Обзор"
                                                    SingleChildScrollView(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
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

                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 5,
                                                                      bottom:
                                                                          5),
                                                              child: Divider(),
                                                            ),

                                                            // Место
                                                            infoRow(
                                                              organizedEvent,
                                                              'assets/icons/icon_location.svg',
                                                              true,
                                                              'Место',
                                                              organizedEvent
                                                                  .address,
                                                            ),

                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 5,
                                                                      bottom:
                                                                          5),
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
                                                                      bottom:
                                                                          5),
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
                                                      ),
                                                    ),
                                                    // Вкладка "Отзывы"
                                                    SingleChildScrollView(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
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
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              SizedBox(
                                                                  height: 16),
                                                              Text(
                                                                'Пока нет отзывов',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .grey,
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
                                                              ListView
                                                                  .separated(
                                                                shrinkWrap:
                                                                    true,
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
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
                                                                            backgroundImage: rewiewsModel.reviews[index].user.photoUrl != "" && rewiewsModel.reviews[index].user.photoUrl != null
                                                                                ? NetworkImage(rewiewsModel.reviews[index].user.photoUrl!)
                                                                                : AssetImage('assets/images/image_profile.png'),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 10),
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                rewiewsModel.reviews[index].user.name,
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  fontWeight: FontWeight.w500,
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
                                                                          height:
                                                                              10),
                                                                      Text(
                                                                        rewiewsModel
                                                                            .reviews[index]
                                                                            .comment,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Gilroy',
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          color:
                                                                              Colors.black,
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
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20,
                                                                        top: 5),
                                                                    child:
                                                                        Divider(),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                      child: SizedBox(
                        height: 59,
                        width: double.infinity,
                        child: !isPublicUser ||
                                completedStatus.contains(organizedEvent.status)
                            ? Container()
                            : ElevatedButton(
                                onPressed: () {
                                  if (profileModel!.isEmailVerified) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    isJoined
                                        ? context.read<ProfileBloc>().add(
                                            ProfileLeaveEvent(
                                                eventId: organizedEvent.id))
                                        : context.read<ProfileBloc>().add(
                                            ProfileJoinEvent(
                                                eventId: organizedEvent.id));
                                  } else if (!profileModel!.isEmailVerified) {
                                    showAlertOKDialog(context, null,
                                        isTitled: true,
                                        title: 'Заполните профиль');
                                  } else if (organizedEvent.freeSlots < 1) {
                                    showAlertOKDialog(context, null,
                                        isTitled: true,
                                        title: 'Подтвердите почту');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: isBlocked
                                      ? mainBlueColor
                                      : (isJoined
                                          ? Colors.red
                                          : Color.fromRGBO(98, 207, 102, 1)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  isBlocked
                                      ? 'Написать организатору'
                                      : (isJoined ? 'Не пойду' : 'Пойду'),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.46,
                                      fontFamily: 'Gilroy'),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: SvgPicture.asset(iconPath),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Gilroy',
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
                      _locationFocusNode.unfocus();
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
                : () {
                    if (title == 'Дата и время') {
                      _dateFocusNode.unfocus();
                    }
                  },
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
                              text: formatDuration(organizedEvent.timeStart,
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
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 2,
                          style: TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 16,
                              color: isLocation ? Colors.blue : Colors.black),
                        ),
                      ),
                      Text(
                        trailing != null
                            ? formatDuration(organizedEvent.timeStart,
                                organizedEvent.timeEnd)
                            : "",
                        style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 16,
                            color: Colors.grey),
                      )
                    ],
                  ),
          ),
      ],
    );
  }
}
