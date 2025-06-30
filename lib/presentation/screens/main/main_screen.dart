import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_main/chat_main_screen.dart';
import 'package:acti_mobile/presentation/screens/events/screens/events_screen.dart';
import 'package:acti_mobile/presentation/screens/events/screens/votes_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_page.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/screens/profile/block_and_delete/block_and_delete_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/get/my_events_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/profile_menu/profile_menu_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/settings/settings_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/update_profile/update_profile_screen.dart';
import 'package:acti_mobile/presentation/widgets/activity_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/my_events_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:provider/provider.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen_provider.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'dart:developer' as developer;
import 'package:toastification/toastification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

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
    await _updateCurrentLocation();
  }

  /// Обновление текущей позиции пользователя
  Future<void> _updateCurrentLocation() async {
    try {
      // iOS-специфичные настройки геолокации
      final locationSettings = Platform.isIOS
          ? geolocator.LocationSettings(
              accuracy: geolocator.LocationAccuracy.high,
              distanceFilter: 10, // 10 метров
              timeLimit: const Duration(seconds: 5),
            )
          : geolocator.LocationSettings(
              accuracy: geolocator.LocationAccuracy.high,
              timeLimit: const Duration(seconds: 5),
            );

      _currentPosition = await geolocator.Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      developer.log(
          'Текущая позиция: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
          name: 'MAIN_SCREEN');

      // Сохраняем позицию в кэш
      await _saveLocationToCache(
          _currentPosition!.latitude, _currentPosition!.longitude);

      // Загружаем события после получения геолокации
      await _loadEvents();
    } catch (e) {
      developer.log('Ошибка при получении позиции: $e', name: 'MAIN_SCREEN');

      // При ошибке используем кэшированную позицию или Москву
      try {
        final lastLocation = await _getLastKnownLocation();
        if (lastLocation != null) {
          _currentPosition = geolocator.Position(
            latitude: lastLocation['latitude'] as double,
            longitude: lastLocation['longitude'] as double,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
          developer.log(
              'Используем кэшированную позицию: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
              name: 'MAIN_SCREEN');
          await _loadEvents();
        }
      } catch (cacheError) {
        developer.log('Ошибка получения кэшированной позиции: $cacheError',
            name: 'MAIN_SCREEN');
      }
    }
  }

  /// Получение последней известной позиции из кэша
  Future<Map<String, double>?> _getLastKnownLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationString = prefs.getString('last_known_location');

      if (locationString != null) {
        final locationData = jsonDecode(locationString) as Map<String, dynamic>;
        final timestamp = locationData['timestamp'] as int;
        final locationTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

        // Проверяем, что данные не старше 24 часов
        if (DateTime.now().difference(locationTime).inHours < 24) {
          return {
            'latitude': locationData['latitude'] as double,
            'longitude': locationData['longitude'] as double,
          };
        }
      }
    } catch (e) {
      developer.log('Ошибка получения кэшированной позиции: $e',
          name: 'MAIN_SCREEN');
    }
    return null;
  }

  /// Сохранение позиции в кэш
  Future<void> _saveLocationToCache(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationData = {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString('last_known_location', jsonEncode(locationData));
      developer.log('Позиция сохранена в кэш: $latitude, $longitude',
          name: 'MAIN_SCREEN');
    } catch (e) {
      developer.log('Ошибка сохранения позиции в кэш: $e', name: 'MAIN_SCREEN');
    }
  }

  /// Обновление позиции при переключении на экран карты
  Future<void> _updateLocationForMapScreen() async {
    if (Provider.of<MainScreenProvider>(context, listen: false).currentIndex ==
        0) {
      // Если переключились на экран карты, обновляем позицию
      await _updateCurrentLocation();
    }
  }

  Future<void> _loadEvents() async {
    if (_currentPosition != null) {
      try {
        developer.log('Загрузка событий в MainScreen:', name: 'MAIN_SCREEN');
        developer.log(
            'Координаты: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
            name: 'MAIN_SCREEN');

        // Запускаем загрузку событий в фоне с таймаутом
        final events = await EventsApi()
            .searchEvents(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          limit: 15, // Уменьшаем с 20 до 15
          offset: 0,
        )
            .timeout(
          const Duration(seconds: 10), // Добавляем таймаут
          onTimeout: () {
            developer.log('Таймаут загрузки событий', name: 'MAIN_SCREEN');
            return null;
          },
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
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Устанавливаем начальный индекс
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MainScreenProvider>(context, listen: false)
          .setIndex(widget.initialIndex);
      // Проверяем разрешения геолокации
      _checkLocationPermission();
    });
  }

  Future<void> _loadProfileIcon() async {
    if (!mounted) return;
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
        if (state is ProfileGotState) {
          if (mounted) {
            setState(() {
              _isVerified = state.profileModel.isEmailVerified;
              _isProfileCompleted = state.profileModel.isProfileCompleted;
            });
          }
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
            const MapPage(),
            EventsScreen(initialEvents: _eventsModel),
            const ChatMainScreen(),
            ProfileMenuScreen(
              onSettingsChanged: (goToSettings) {
                if (goToSettings == true) {
                  provider.setIndex(6);
                }
              },
            ),
            const MyEventsScreen(),
            const VotesScreen(),
            SettingsScreen(
              notificationsEnabled: true, // или получить из профиля
              onBack: () {
                provider.setIndex(3); // Возврат к профилю
              },
            ),
          ];

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              top: false,
              child: Stack(
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

                          // Обновляем позицию при переключении на экран карты
                          if (index == 0) {
                            _updateLocationForMapScreen();
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
            ),
          );
        },
      ),
    );
  }
}
