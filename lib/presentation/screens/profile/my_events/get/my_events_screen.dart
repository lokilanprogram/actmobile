import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
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
  String selectedTab = 'mine';
  bool isMineEvents = true;
  ProfileEventModels? profileEventModels;
  ProfileEventModels? profileVisitedEventModels;
  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    setState(() {
      isLoading = true;
    });
    context.read<ProfileBloc>().add(ProfileGetListEventsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileAcceptedUserOnActivityState) {
          initialize();
        }
        if (state is ProfileCanceledActivityState) {
          initialize();
        }
        if (state is ProfileUpdatedState) {
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
                    event.status == 'canceled') ??
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
          appBar: isLoading
              ? null
              : AppBarWidget(
                  title: 'События',
                ),
          extendBody: true,
          body: isLoading
              ? LoaderWidget()
              : Stack(
                  children: [
                    Positioned.fill(
                      child: SafeArea(
                          child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        child: ListView(
                          children: [
                            TabBarWidget(
                              firshTabText: 'Мои',
                              secondTabText: 'Посещённые',
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
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                                    hintText: 'Поиск',
                                    hintStyle: TextStyle(
                                        fontFamily: 'Gilroy',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            isMineEvents == true
                                ? (profileEventModels == null ||
                                        profileEventModels!.events.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 100),
                                            Text(
                                              'У вас нет ивентов',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            ElevatedButton(
                                              onPressed: () {
                                                initialize();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF4293EF),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 14,
                                                    horizontal: 32),
                                              ),
                                              child: Text(
                                                'Обновить',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : RefreshIndicator(
                                        onRefresh: () async {
                                          initialize();
                                        },
                                        child: ListView(
                                          children: [
                                            Column(
                                              children: profileEventModels!
                                                  .events
                                                  .where((event) =>
                                                      event.status !=
                                                          'completed' &&
                                                      event.status !=
                                                          'canceled')
                                                  .map((event) {
                                                return MyCardEventWidget(
                                                  isCompletedEvent: false,
                                                  isPublicUser: false,
                                                  organizedEvent: event,
                                                );
                                              }).toList(),
                                            ),
                                            hasCompleted
                                                ? Column(
                                                    children: [
                                                      DashedLineWithText(),
                                                      Column(
                                                        children: profileEventModels!
                                                            .events
                                                            .where((event) =>
                                                                event.status ==
                                                                    'completed' ||
                                                                event.status ==
                                                                    'canceled')
                                                            .map((event) {
                                                          return MyCardEventWidget(
                                                            isCompletedEvent:
                                                                true,
                                                            isPublicUser: false,
                                                            organizedEvent:
                                                                event,
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ],
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      ))
                                : (profileVisitedEventModels == null ||
                                        profileVisitedEventModels!
                                            .events.isEmpty
                                    ? Center(
                                        child: Text(
                                          'Пусто',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : RefreshIndicator(
                                        onRefresh: () async {
                                          initialize();
                                        },
                                        child: ListView(
                                          children: profileVisitedEventModels!
                                              .events
                                              .map((event) {
                                            return MyCardEventWidget(
                                              isCompletedEvent: false,
                                              isPublicUser: true,
                                              organizedEvent: event,
                                            );
                                          }).toList(),
                                        ),
                                      )),
                            SizedBox(
                              height: 150,
                            ),
                          ],
                        ),
                      )),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ActivityBarWidget(isVerified: isVerified),
                              SizedBox(
                                height: 15,
                              ),
                              CustomNavBarWidget(
                                  selectedIndex: 4,
                                  onTabSelected: (index) {
                                    if (index == 0) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MapScreen(
                                                    selectedScreenIndex: 0,
                                                  )));
                                    }
                                    if (index == 2) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MapScreen(
                                                  selectedScreenIndex: 2)));
                                    }
                                    if (index == 3) {
                                      Navigator.pop(context);
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
    );
  }
}
