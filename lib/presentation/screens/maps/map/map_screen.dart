import 'package:acti_mobile/configs/geolocator_utils.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/domain/deeplinks/deeplinks.dart';
import 'package:acti_mobile/domain/websocket/websocket.dart';
import 'package:acti_mobile/presentation/screens/events/screens/events_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/event/widgets/card_event_on_map.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'dart:developer' as developer;
import 'package:acti_mobile/main.dart';
import 'package:screenshot/screenshot.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/marker.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/data/models/searched_events_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_main/chat_main_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/screens/maps/event/widgets/events_home_map_widget.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/get/my_events_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/profile_menu/profile_menu_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:acti_mobile/presentation/screens/events/widgets/filter_bottom_sheet.dart';
import 'package:acti_mobile/presentation/screens/events/providers/filter_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MapScreen extends StatefulWidget {
  final int selectedScreenIndex;
  const MapScreen({super.key, required this.selectedScreenIndex});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  WidgetsToImageController controller = WidgetsToImageController();
  ScreenshotController screenshotController = ScreenshotController();
  int selectedIndex = 0;
  MapboxMap? mapboxMap;
  late geolocator.LocationPermission currentPermission;
  Position currentSelectedPosition = Position(37.6173, 55.7558); // Москва
  Position? currentUserPosition;
  double currentZoom = 16;
  bool isLoading = false;
  bool showEvents = false;
  bool showSettings = false;
  DeepLinkService? _deepLinkService;
  DraggableScrollableController sheetController =
      DraggableScrollableController();
  SearchedEventsModel? searchedEventsModel;

  late PointAnnotationManager pointAnnotationManager;
  final String eventsSourceId = "events-source";
  final String eventsLayerId = "events-layer";
  final String iconImageIdPrefix = "event-icon-";

  _onScroll(
    MapContentGestureContext gestureContext,
  ) async {
    double distance = geolocator.Geolocator.distanceBetween(
      currentSelectedPosition.lat.toDouble(),
      currentSelectedPosition.lng.toDouble(),
      gestureContext.point.coordinates.lat.toDouble(),
      gestureContext.point.coordinates.lng.toDouble(),
    );

    if (distance > 100000) {
      print('more than 100 km');
      setState(() {
        currentSelectedPosition = Position(
            gestureContext.point.coordinates.lng.toDouble(),
            gestureContext.point.coordinates.lat.toDouble());
      });
      context.read<ProfileBloc>().add(SearchEventsOnMapEvent(
          latitude: gestureContext.point.coordinates.lat.toDouble(),
          longitude: gestureContext.point.coordinates.lng.toDouble()));
    }
  }

  _onTap(
    MapContentGestureContext context,
  ) async {
    const double threshold = 0.001;

    for (var event in searchedEventsModel!.events) {
      final distanceLat =
          (event.latitude! - context.point.coordinates.lat).abs();
      final distanceLng =
          (event.longitude! - context.point.coordinates.lng).abs();

      if (distanceLat < threshold && distanceLng < threshold) {
        await Get.bottomSheet(
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            CardEventOnMap(
              organizedEvent: event,
            ));
      }
      print(
          '${context.point.coordinates.lng} ${context.point.coordinates.lat}');
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
    sheetController.addListener(() async {
      if (sheetController.size <= 0.5) {
        setState(() {
          showEvents = false;
        });
      }
      _deepLinkService!.dispose();
    });
  }

  @override
  void dispose() {
    // Dispose Mapbox resources
    //mapboxMap?.dispose();
    // pointAnnotationManager?.dispose(); // PointAnnotationManager might not have a public dispose, depending on the version/implementation detail, disposing mapboxMap usually handles managers.
    _deepLinkService?.dispose();
    sheetController.dispose();
    super.dispose();
  }

  void initialize() async {
    setState(() {
      isLoading = true;
      selectedIndex = widget.selectedScreenIndex;
      _deepLinkService = DeepLinkService(navigatorKey);
    });
    if (_deepLinkService != null) {
      await _deepLinkService!.initDeepLinks();
    }
    final permission = await geolocator.Geolocator.checkPermission();
    setState(() {
      currentPermission = permission;
    });
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      try {
        connectToOnlineStatus(accessToken);
      } catch (e) {
        developer.log('Ошибка при подключении к WebSocket: $e',
            name: 'MAP_SCREEN');
      }
    } else {
      developer.log('Access token не найден', name: 'MAP_SCREEN');
    }
    if (currentPermission.name == 'denied') {
      final permission = await geolocator.Geolocator.requestPermission();
      setState(() {
        currentPermission = permission;
      });
    }
    if (currentPermission.name != 'denied') {
      if (await checkGeolocator()) {
        final position = await geolocator.Geolocator.getCurrentPosition();
        setState(() {
          currentUserPosition = Position(position.longitude, position.latitude);
          currentSelectedPosition =
              Position(position.longitude, position.latitude);
        });
      } else {
        const defaultLatitude = 55.7558;
        const defaultLongitude = 37.6173;

        setState(() {
          currentSelectedPosition = Position(defaultLongitude, defaultLatitude);
        });
      }
    } else {
      setState(() {
        currentUserPosition = null;
        currentSelectedPosition =
            Position(37.60709779391965, 55.73523399526778);
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Не удалось получить местоположение',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
    context.read<ProfileBloc>().add(InitializeMapEvent(
        latitude: currentSelectedPosition.lat.toDouble(),
        longitude: currentSelectedPosition.lng.toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      MapWidget(
        onStyleLoadedListener: (styleLoadedEventData) async {
          if (currentUserPosition != null) {
            await addUserIconToStyle(mapboxMap!);
          }
          if (searchedEventsModel != null && mapboxMap != null) {
            for (var event in searchedEventsModel!.events) {
              final result = await screenshotController.captureFromWidget(
                CategoryMarker(
                    title: event.category!.name,
                    iconUrl: event.category!.iconPath),
              );
              await addEventIconFromUrl(
                  mapboxMap!, 'pointer:${event.id}', result);
              final pointAnnotationOptions = PointAnnotationOptions(
                geometry: Point(
                    coordinates: Position(event.longitude!, event.latitude!)),
                iconSize: 0.75,
                image: result,
                iconImage: 'pointer:${event.id}',
              );
              await pointAnnotationManager.create(pointAnnotationOptions);
            }
          }
        },
        onScrollListener: _onScroll,
        onTapListener: _onTap,
        styleUri: 'mapbox://styles/acti/cmbf00t92005701s5d84c1cqp',
        cameraOptions: CameraOptions(
          zoom: currentZoom,
          center: Point(
            coordinates: Position(
              currentSelectedPosition.lng,
              currentSelectedPosition.lat,
            ),
          ),
        ),
        key: const ValueKey("MapWidget"),
        onMapCreated: _onMapCreated,
      ),
      const EventsScreen(),
      ChatMainScreen(),
      ProfileMenuScreen(
        onSettingsChanged: (value) {
          setState(() {
            showSettings = value;
          });
        },
      ),
    ];

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state is InitializeMapState) {
          setState(() {
            searchedEventsModel = state.searchedEventsModel;
            isLoading = false;
          });
        }
        if (state is SearchedEventsOnMapState) {
          setState(() {
            final existingIds =
                searchedEventsModel?.events.map((e) => e.id).toSet() ?? {};
            final newUniqueEvents = state.searchedEventsModel.events
                .where((event) => !existingIds.contains(event.id))
                .toList();

            searchedEventsModel?.events.addAll(newUniqueEvents);
          });

          // Ensure mapboxMap and pointAnnotationManager are initialized before adding annotations
          if (mapboxMap != null) {
            for (var event in searchedEventsModel!.events) {
              final result = await screenshotController.captureFromWidget(
                CategoryMarker(
                    title: event.category!.name,
                    iconUrl: event.category!.iconPath),
              );
              await addEventIconFromUrl(
                  mapboxMap!, 'pointer:${event.id}', result);
              final pointAnnotationOptions = PointAnnotationOptions(
                geometry: Point(
                    coordinates: Position(event.longitude!, event.latitude!)),
                iconSize: 0.75,
                image: result,
                iconImage: 'pointer:${event.id}',
              );
              await pointAnnotationManager.create(pointAnnotationOptions);
            }
          }
        }
        if (state is ProfileUpdatedState) {
          initialize();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
          onWillPop: () async {
            SystemNavigator.pop();
            return false;
          },
          child: isLoading
              ? const LoaderWidget()
              : Stack(
                  children: [
                    // Use IndexedStack to keep all screens alive
                    IndexedStack(
                      index: selectedIndex,
                      children: screens,
                    ),

                    // Map controls should only be visible on the map screen (selectedIndex == 0)
                    if (selectedIndex == 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: buildMapControls(),
                      ),

                    if (showEvents &&
                        selectedIndex ==
                            0) // Show events list only on map screen
                      DraggableScrollableSheet(
                        controller: sheetController,
                        initialChildSize: 0.8, // стартовая высота
                        builder: (context, scrollController) {
                          return EventsHomeListOnMapWidget(
                              scrollController: scrollController);
                        },
                      ),

                    // My Events button (assuming it's part of the profile screen)
                    // This logic might need to be moved inside ProfileMenuScreen
                    if (selectedIndex == 3 && !showSettings)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 140),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyEventsScreen()));
                            },
                            child: Material(
                              elevation: 1.2,
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                height: 59,
                                width: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                  color: mainBlueColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                        'assets/icons/icon_event_bar.svg'),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Мои события',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Gilroy',
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: CustomNavBarWidget(
                          selectedIndex: selectedIndex,
                          onTabSelected: (int index) async {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildMapControls() {
    // Ensure controls are only built when selectedIndex is 0
    // This check is also done in the Stack, but good to be explicit here too.
    if (selectedIndex != 0) return SizedBox.shrink();

    return Container(
      width: 59,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: SvgPicture.asset('assets/left_drawer/filter.svg'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FilterBottomSheet(
                    currentPosition: currentUserPosition != null
                        ? geolocator.Position(
                            latitude: currentUserPosition!.lat.toDouble(),
                            longitude: currentUserPosition!.lng.toDouble(),
                            timestamp: DateTime.now(),
                            accuracy: 0,
                            altitude: 0,
                            heading: 0,
                            speed: 0,
                            speedAccuracy: 0,
                            altitudeAccuracy: 0,
                            headingAccuracy: 0)
                        : null,
                    onApplyFilters: () {
                      final filterProvider =
                          Provider.of<FilterProvider>(context, listen: false);

                      // Очищаем текущие маркеры
                      pointAnnotationManager.deleteAll();

                      // Определяем координаты для поиска
                      double searchLat = currentSelectedPosition.lat.toDouble();
                      double searchLng = currentSelectedPosition.lng.toDouble();

                      // Если выбрана точка на карте в фильтре, используем её
                      if (filterProvider.selectedMapAddressModel != null) {
                        searchLat =
                            filterProvider.selectedMapAddressModel!.latitude ??
                                searchLat;
                        searchLng =
                            filterProvider.selectedMapAddressModel!.longitude ??
                                searchLng;
                      }

                      // Определяем радиус поиска
                      int radius = filterProvider.selectedRadius
                          .round(); // используем значение в километрах
                      // Ограничиваем радиус до 100 км
                      if (radius > 100) {
                        radius = 100;
                      }

                      // Формируем список ограничений
                      List<String> restrictions = [];
                      if (filterProvider.isAnimalsAllowedSelected) {
                        restrictions.add('withAnimals');
                      }

                      if (filterProvider.isFreeSelected) {
                        restrictions.add('isUnlimited');
                      }

                      if (filterProvider.selectedAgeRestrictions
                          .contains('isAdults')) {
                        restrictions.add('isKidsNotAllowed');
                      } else if (filterProvider.selectedAgeRestrictions
                          .contains('isKidsAllowed')) {
                        restrictions.add('withKids');
                      }

                      // Определяем длительность
                      int? durationMin;
                      int? durationMax;
                      if (filterProvider.selectedDurationFilter == 'short') {
                        durationMin = 1;
                        durationMax = 2;
                      } else if (filterProvider.selectedDurationFilter ==
                          'medium') {
                        durationMin = 3;
                        durationMax = 5;
                      } else if (filterProvider.selectedDurationFilter ==
                          'long') {
                        durationMin = 6;
                        durationMax = 24;
                      }

                      // Логируем выбранные фильтры
                      developer.log('Выбранные фильтры:', name: 'MAP_SEARCH');
                      developer.log('Радиус: $radius км', name: 'MAP_SEARCH');
                      developer.log('Ограничения: $restrictions',
                          name: 'MAP_SEARCH');
                      developer.log(
                          'Длительность: $durationMin - $durationMax часов',
                          name: 'MAP_SEARCH');
                      developer.log(
                          'Категории (${filterProvider.selectedCategoryIds.length}): ${filterProvider.selectedCategoryIds.join(", ")}',
                          name: 'MAP_SEARCH');
                      developer.log(
                          'Цена: ${filterProvider.isFreeSelected ? "Бесплатно" : "${filterProvider.priceMinText} - ${filterProvider.priceMaxText}"}',
                          name: 'MAP_SEARCH');
                      developer.log(
                          'Дата: ${filterProvider.selectedDateFrom} - ${filterProvider.selectedDateTo}',
                          name: 'MAP_SEARCH');
                      developer.log(
                          'Время: ${filterProvider.selectedTimeFrom} - ${filterProvider.selectedTimeTo}',
                          name: 'MAP_SEARCH');

                      // Форматируем даты в формат YYYY-MM-DD
                      String? formattedDateFrom;
                      String? formattedDateTo;
                      if (filterProvider.selectedDateFrom != null) {
                        formattedDateFrom = DateFormat('yyyy-MM-dd')
                            .format(filterProvider.selectedDateFrom!);
                      }
                      if (filterProvider.selectedDateTo != null) {
                        formattedDateTo = DateFormat('yyyy-MM-dd')
                            .format(filterProvider.selectedDateTo!);
                      }

                      // Выполняем поиск с фильтрами
                      context.read<ProfileBloc>().add(SearchEventsOnMapEvent(
                            latitude: searchLat,
                            longitude: searchLng,
                            filters: {
                              'radius': radius,
                              'restrictions': restrictions,
                              'duration_min': durationMin,
                              'duration_max': durationMax,
                              'category_ids':
                                  filterProvider.selectedCategoryIds,
                              'price_min': filterProvider.isFreeSelected
                                  ? 0
                                  : double.tryParse(
                                      filterProvider.priceMinText),
                              'price_max': filterProvider.isFreeSelected
                                  ? 0
                                  : double.tryParse(
                                      filterProvider.priceMaxText),
                              'date_from': formattedDateFrom,
                              'date_to': formattedDateTo,
                              'time_from': filterProvider.selectedTimeFrom,
                              'time_to': filterProvider.selectedTimeTo,
                            },
                          ));
                    },
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () async {
                if (mapboxMap != null) {
                  final camera = await mapboxMap!.getCameraState();
                  await mapboxMap!
                      .setCamera(CameraOptions(zoom: camera.zoom - 1));
                }
              },
              icon: SvgPicture.asset('assets/left_drawer/minus.svg'),
            ),
            IconButton(
              onPressed: () async {
                if (mapboxMap != null) {
                  final camera = await mapboxMap!.getCameraState();
                  await mapboxMap!
                      .setCamera(CameraOptions(zoom: camera.zoom + 1));
                }
              },
              icon: SvgPicture.asset('assets/left_drawer/plus.svg'),
            ),
            IconButton(
              onPressed: () async {
                if (currentUserPosition != null && mapboxMap != null) {
                  await mapboxMap!.setCamera(CameraOptions(
                      center: Point(
                          coordinates: Position(currentUserPosition!.lng,
                              currentUserPosition!.lat)),
                      zoom: currentZoom));
                } else {
                  // Re-initialize if location is not available
                  if (await checkGeolocator()) initialize();
                }
              },
              icon: SvgPicture.asset('assets/left_drawer/my_location.svg'),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    setState(() {
      this.mapboxMap = mapboxMap;
    });
    final pointNewAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    setState(() {
      pointAnnotationManager = pointNewAnnotationManager;
    });
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await mapboxMap.logo.updateSettings(LogoSettings(enabled: false));
    await mapboxMap.attribution
        .updateSettings(AttributionSettings(enabled: false));
    await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));

    // Add existing events to the map after it's created if they are already loaded
    if (searchedEventsModel != null) {
      for (var event in searchedEventsModel!.events) {
        final result = await screenshotController.captureFromWidget(
          CategoryMarker(
              title: event.category!.name, iconUrl: event.category!.iconPath),
        );
        await addEventIconFromUrl(mapboxMap, 'pointer:${event.id}',
            result); // Use mapboxMap directly here
        final pointAnnotationOptions = PointAnnotationOptions(
          geometry:
              Point(coordinates: Position(event.longitude!, event.latitude!)),
          iconSize: 0.75,
          image: result,
          iconImage: 'pointer:${event.id}',
        );
        await pointAnnotationManager.create(pointAnnotationOptions);
      }
    }
  }
}
