import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/events/screens/events_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/widget/my_events_card.dart';
import 'package:acti_mobile/presentation/widgets/activity_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/app_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/dashed_line_painter.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:acti_mobile/presentation/widgets/tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  bool isLoading = false;
  bool isVerified = false;
  bool hasCompleted = false;
  bool hasCompletedVisited = false;
  String selectedTab = 'mine';
  bool isMineEvents = true;
  ProfileEventModels? profileEventModels;
  ProfileEventModels? profileVisitedEventModels;

  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initialize() {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    context.read<ProfileBloc>().add(ProfileGetListEventsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final String query = _controller.text.trim().toLowerCase();

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileAcceptedUserOnActivityState ||
            state is ProfileCanceledActivityState ||
            state is ProfileUpdatedState) {
          initialize();
        }
        if (state is ProfileGotListEventsState) {
          setState(() {
            isLoading = false;
            isVerified = state.isVerified;
            profileEventModels = state.profileEventsModels;
            profileVisitedEventModels = state.profileVisitedEventsModels;
            hasCompleted = profileEventModels?.events.any((event) =>
                    event.status == 'completed' ||
                    event.status == 'canceled' ||
                    event.status == 'rejected') ??
                false;
            hasCompletedVisited = profileVisitedEventModels?.events.any(
                    (event) =>
                        event.status == 'completed' ||
                        event.status == 'canceled' ||
                        event.status == 'rejected') ??
                false;
          });
        }
        if (state is ProfileGotListEventsErrorState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'События',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 23,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.topCenter,
          children: [
            isLoading
                ? LoaderWidget()
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          TabBarWidget(
                            firshTabText: 'Мои',
                            secondTabText: 'Учавствую',
                            selectedTab: selectedTab,
                            onTapMine: () {
                              setState(() {
                                selectedTab = "mine";
                                isMineEvents = true;
                              });
                            },
                            onTapVisited: () {
                              setState(() {
                                selectedTab = "notMine";
                                isMineEvents = false;
                              });
                            },
                            requestLentgh: null,
                            recommendedLentgh: null,
                          ),
                          const SizedBox(height: 25),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(25)),
                            child: TextFormField(
                              controller: _controller,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide.none),
                                  prefixIcon:
                                      Icon(Icons.search, color: Colors.grey),
                                  hintText: 'Поиск',
                                  hintStyle: TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400)),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Expanded(
                            child: SizedBox(
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  initialize();
                                },
                                child: ListView(
                                  children: [
                                    if (isMineEvents)
                                      buildMyEvents(query)
                                    else
                                      buildVisitedEvents(query),
                                    const SizedBox(height: 150),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            Positioned(
              bottom: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActivityBarWidget(isVerified: isVerified),
                  const SizedBox(height: 15),
                  CustomNavBarWidget(
                    selectedIndex: 4,
                    onTabSelected: (index) {
                      if (index == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MapScreen(selectedScreenIndex: 0)),
                        );
                      }
                      if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventsScreen()),
                        );
                      }
                      if (index == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MapScreen(selectedScreenIndex: 2)),
                        );
                      }
                      if (index == 3) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMyEvents(String query) {
    if (profileEventModels == null || profileEventModels!.events.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Text(
              'У вас нет ивентов',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: initialize,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4293EF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              ),
              child: const Text(
                'Обновить',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    final activeEvents = profileEventModels!.events.where((event) =>
        event.status != 'completed' &&
        event.status != 'canceled' &&
        event.status != 'rejected' &&
        event.title.toLowerCase().contains(query));

    final completedEvents = profileEventModels!.events.where((event) =>
        (event.status == 'completed' ||
            event.status == 'canceled' ||
            event.status == 'rejected') &&
        event.title.toLowerCase().contains(query));

    return Column(
      children: [
        ...activeEvents.map((event) => MyCardEventWidget(
              isCompletedEvent: false,
              isPublicUser: false,
              organizedEvent: event,
            )),
        if (hasCompleted && completedEvents.isNotEmpty) ...[
          DashedLineWithText(),
          ...completedEvents.map((event) => MyCardEventWidget(
                isCompletedEvent: true,
                isPublicUser: false,
                organizedEvent: event,
              )),
        ]
      ],
    );
  }

  Widget buildVisitedEvents(String query) {
    if (profileVisitedEventModels == null ||
        profileVisitedEventModels!.events.isEmpty) {
      return Center(
        child: Text(
          'Пусто',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
      );
    }

    final activeEvents = profileVisitedEventModels!.events.where((event) =>
        event.status != 'completed' &&
        event.status != 'canceled' &&
        event.status != 'rejected' &&
        event.title.toLowerCase().contains(query));

    final completedEvents = profileVisitedEventModels!.events.where((event) =>
        (event.status == 'completed' ||
            event.status == 'canceled' ||
            event.status == 'rejected') &&
        event.title.toLowerCase().contains(query));

    return Column(
      children: [
        ...activeEvents.map((event) => MyCardEventWidget(
              isCompletedEvent: false,
              isPublicUser: false,
              organizedEvent: event,
            )),
        if (hasCompletedVisited && completedEvents.isNotEmpty) ...[
          DashedLineWithText(),
          ...completedEvents.map((event) => MyCardEventWidget(
                isCompletedEvent: true,
                isPublicUser: false,
                organizedEvent: event,
              )),
        ]
      ],
    );
  }
}
