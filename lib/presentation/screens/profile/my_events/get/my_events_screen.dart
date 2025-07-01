import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/events/screens/events_screen.dart';
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
  bool isRefreshing = false;
  bool isVerified = false;
  bool isProfileCompleted = false;
  bool hasCompleted = false;
  bool hasCompletedVisited = false;
  String selectedTab = 'mine';
  bool isMineEvents = true;
  ProfileEventModels? profileEventModels;
  ProfileEventModels? profileVisitedEventModels;

  late final TextEditingController _controller;

  late final ScrollController _scrollControllerMy;
  bool isLoadingMoreMy = false;

  late final ScrollController _scrollControllerVisited;
  bool isLoadingMoreVisited = false;

  @override
  void initState() {
    print('MyEventsScreen initState'); // Отладочная информация
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {});
    });
    _scrollControllerMy = ScrollController();
    _scrollControllerMy.addListener(_onScrollMy);
    _scrollControllerVisited = ScrollController();
    _scrollControllerVisited.addListener(_onScrollVisited);
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollControllerMy.dispose();
    _scrollControllerVisited.dispose();
    super.dispose();
  }

  void initialize() {
    print('MyEventsScreen initialize'); // Отладочная информация
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    context.read<ProfileBloc>().add(ProfileGetListEventsEvent());
  }

  void _onScrollMy() {
    final state = context.read<ProfileBloc>().state;
    if (_scrollControllerMy.position.pixels >=
        _scrollControllerMy.position.maxScrollExtent - 200) {
      if (!isLoadingMoreMy &&
          state is ProfileGotListEventsState &&
          state.hasMoreEvents) {
        if (!mounted) return;
        setState(() => isLoadingMoreMy = true);
        context
            .read<ProfileBloc>()
            .add(ProfileGetListEventsEvent(loadMoreMy: true));
      }
    }
  }

  void _onScrollVisited() {
    final state = context.read<ProfileBloc>().state;
    if (_scrollControllerVisited.position.pixels >=
        _scrollControllerVisited.position.maxScrollExtent - 200) {
      if (!isLoadingMoreVisited &&
          state is ProfileGotListEventsState &&
          state.hasMoreVisitedEvents) {
        if (!mounted) return;
        setState(() => isLoadingMoreVisited = true);
        context
            .read<ProfileBloc>()
            .add(ProfileGetListEventsEvent(loadMoreVisited: true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('MyEventsScreen build'); // Отладочная информация
    final String query = _controller.text.trim().toLowerCase();

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileAcceptedUserOnActivityState ||
            state is ProfileCanceledActivityState ||
            state is ProfileUpdatedState) {
          initialize();
        }
        if (state is ProfileGotListEventsState) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
            isRefreshing = false;
            isVerified = state.isVerified;
            isLoadingMoreMy = false;
            isLoadingMoreVisited = false;
            isProfileCompleted = state.isProfileCompleted;
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
          if (!mounted) return;
          setState(() {
            isLoading = false;
            isRefreshing = false;
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
                            secondTabText: 'Участвую',
                            selectedTab: selectedTab,
                            onTapMine: () {
                              if (!mounted) return;
                              setState(() {
                                selectedTab = "mine";
                                isMineEvents = true;
                              });
                            },
                            onTapVisited: () {
                              if (!mounted) return;
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
                              textCapitalization: TextCapitalization.sentences,
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
                                  if (!mounted) return;
                                  setState(() {
                                    isRefreshing = true;
                                    context
                                        .read<ProfileBloc>()
                                        .add(ProfileGetListEventsEvent());
                                  });
                                },
                                child: isRefreshing
                                    ? LoaderWidget()
                                    : ListView(
                                        controller: isMineEvents
                                            ? _scrollControllerMy
                                            : _scrollControllerVisited,
                                        physics: AlwaysScrollableScrollPhysics(),
                                        children: [
                                          if (isMineEvents)
                                            buildMyEvents(query)
                                          else
                                            buildVisitedEvents(query),
                                          if ((isMineEvents &&
                                                  isLoadingMoreMy) ||
                                              (!isMineEvents &&
                                                  isLoadingMoreVisited))
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16),
                                                child: LoaderWidget(),
                                              ),
                                            ),
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
              onPressed: () {
                if (!mounted) return;
                initialize();
              },
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
              isPublicUser: true,
              organizedEvent: event,
            )),
        if (hasCompletedVisited && completedEvents.isNotEmpty) ...[
          DashedLineWithText(),
          ...completedEvents.map((event) => MyCardEventWidget(
                isCompletedEvent: true,
                isPublicUser: true,
                organizedEvent: event,
              )),
        ]
      ],
    );
  }
}
