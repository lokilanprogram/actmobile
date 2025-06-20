import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_main/chat_main_screen.dart';
import 'package:acti_mobile/presentation/screens/events/screens/events_screen.dart';
import 'package:acti_mobile/presentation/screens/events/screens/votes_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/screens/profile/block_and_delete/block_and_delete_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/get/my_events_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/profile_menu/profile_menu_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/update_profile/update_profile_screen.dart';
import 'package:acti_mobile/presentation/widgets/activity_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/my_events_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:provider/provider.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen_provider.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'dart:developer' as developer;
import 'package:toastification/toastification.dart';

import 'package:acti_mobile/data/models/all_events_model.dart' as all_events;

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final bool showUpdateProfileOnStart;
  final ProfileModel? profileModel;
  const MainScreen(
      {super.key,
      this.initialIndex = 0,
      this.showUpdateProfileOnStart = false,
      this.profileModel});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final bool _showSettings = false;
  bool _isVerified = false;
  bool _isProfileCompleted = false;
  all_events.AllEventsModel? _eventsModel;
  geolocator.Position? _currentPosition;
  String? _profileIconUrl;
  late ProfileModel profileModel;
  bool _didShowUpdateProfile = false;

  final List<Widget> _screens = [
    MapScreen(),
    const EventsScreen(),
    const ChatMainScreen(),
    ProfileMenuScreen(onSettingsChanged: null),
    const MyEventsScreen(),
    const VotesScreen(),
    // UpdateProfileScreen(
    //                                                           profileModel:
    //                                                               profileModel,
    //                                                         )
  ];

  Future<void> _checkLocationPermission() async {
    developer.log('Проверка разрешений геолокации', name: 'MAIN_SCREEN');

    bool serviceEnabled;
    geolocator.LocationPermission permission;

    // Проверяем, включена ли служба геолокации
    serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      developer.log('Служба геолокации отключена', name: 'MAIN_SCREEN');
      toastification.show(
        context: context,
        title: Text('Для работы приложения необходимо включить геолокацию'),
        type: ToastificationType.warning,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topRight,
      );
      return;
    }

    // Проверяем разрешения
    permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied) {
      developer.log('Запрашиваем разрешение на геолокацию',
          name: 'MAIN_SCREEN');
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.denied) {
        developer.log('Разрешение на геолокацию отклонено',
            name: 'MAIN_SCREEN');
        toastification.show(
          context: context,
          title: Text('Для работы приложения необходим доступ к геолокации'),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.topRight,
        );
        return;
      }
    }

    if (permission == geolocator.LocationPermission.deniedForever) {
      developer.log('Разрешение на геолокацию отклонено навсегда',
          name: 'MAIN_SCREEN');
      toastification.show(
        context: context,
        title: Text(
            'Для работы приложения необходим доступ к геолокации. Пожалуйста, включите его в настройках устройства'),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topRight,
      );
      return;
    }

    developer.log('Разрешение на геолокацию получено', name: 'MAIN_SCREEN');
    // Получаем текущую позицию
    try {
      _currentPosition = await geolocator.Geolocator.getCurrentPosition();
      developer.log(
          'Текущая позиция: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
          name: 'MAIN_SCREEN');

      // Загружаем события после получения геолокации
      await _loadEvents();
    } catch (e) {
      developer.log('Ошибка при получении позиции: $e', name: 'MAIN_SCREEN');
    }
  }

  Future<void> _loadEvents() async {
    if (_currentPosition != null) {
      try {
        developer.log('Загрузка событий в MainScreen:', name: 'MAIN_SCREEN');
        developer.log(
            'Координаты: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
            name: 'MAIN_SCREEN');

        final events = await EventsApi().searchEvents(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          // radius: 50, // Уменьшаем радиус до 50 км
          limit: 20, // Уменьшаем лимит до 20
          offset: 0, // Добавляем offset
        );

        developer.log('Получено событий: ${events?.events.length ?? 0}',
            name: 'MAIN_SCREEN');

        if (mounted) {
          setState(() {
            _eventsModel = events;
          });
        }
      } catch (e) {
        developer.log('Ошибка при загрузке событий: $e', name: 'MAIN_SCREEN');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _profileIconUrl = null;
    _loadProfileIcon();
    // Устанавливаем начальный индекс
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MainScreenProvider>(context, listen: false)
          .setIndex(widget.initialIndex);
      // Проверяем разрешения геолокации
      _checkLocationPermission();
    });
  }

  Future<void> _loadProfileIcon() async {
    try {
      final profile = await ProfileApi().getProfile();
      setState(() {
        _profileIconUrl = profile?.photoUrl;
      });
    } catch (e) {
      _profileIconUrl = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showUpdateProfileOnStart &&
          !_didShowUpdateProfile &&
          widget.profileModel != null) {
        _didShowUpdateProfile = true;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                UpdateProfileScreen(profileModel: widget.profileModel!),
          ),
        );
      }
    });
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileGotListEventsState) {
          setState(() {
            _isVerified = state.isVerified;
            _isProfileCompleted = state.isProfileCompleted;
          });
        } else if (state is ProfileBlockedAdminState) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BlockedScreen(profileModel: state.profileModel)),
              (route) => false);
        } else if (state is ProfileDeleteAdminState) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DeletedScreen(profileModel: state.profileModel)),
              (route) => false);
        }
      },
      child: Consumer<MainScreenProvider>(
        builder: (context, provider, child) {
          // Обновляем список экранов с учетом полученных данных
          final screens = [
            MapScreen(),
            EventsScreen(initialEvents: _eventsModel),
            const ChatMainScreen(),
            ProfileMenuScreen(onSettingsChanged: null),
            const MyEventsScreen(),
            const VotesScreen(),
          ];

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                IndexedStack(
                  index: provider.currentIndex,
                  children: screens,
                ),
                if (provider.currentIndex == 4)
                  Positioned(
                    left: 30,
                    right: 30,
                    bottom: 120,
                    child: ActivityBarWidget(
                      isVerified: _isVerified,
                      isProfileCompleted: _isProfileCompleted,
                    ),
                  ),
                if (provider.currentIndex == 1)
                  Positioned(
                    left: 30,
                    right: 30,
                    bottom: 120,
                    child: ActivityBarWidget(
                      isVerified: _isVerified,
                      isProfileCompleted: _isProfileCompleted,
                    ),
                  ),
                if (provider.currentIndex == 3)
                  Positioned(
                    left: 30,
                    right: 30,
                    bottom: 120,
                    child: MyEventsWidget(
                      onTap: () {
                        provider.setIndex(4);
                      },
                    ),
                  ),
                Positioned(
                  left: 30,
                  right: 30,
                  bottom: 30,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: mainBlueColor.withAlpha(180),
                          blurRadius: 100,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: CustomNavBarWidget(
                      selectedIndex: provider.currentIndex == 5
                          ? 1
                          : provider.currentIndex,
                      onTabSelected: (index) {
                        if (index == 1) {
                          provider.setIndex(1);
                        } else if (index == 5) {
                          provider.setIndex(5);
                        } else {
                          provider.setIndex(index);
                        }
                        // Обновляем состояние при изменении индекса
                        // context
                        //     .read<ProfileBloc>()
                        //     .add(ProfileGetListEventsEvent());
                      },
                      profileIconUrl: _profileIconUrl,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
