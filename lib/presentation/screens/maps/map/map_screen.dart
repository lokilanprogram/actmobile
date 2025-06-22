import 'dart:io';
import 'package:acti_mobile/configs/geolocator_utils.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/domain/api/map/map_api.dart';
import 'package:acti_mobile/domain/deeplinks/deeplinks.dart';
import 'package:acti_mobile/domain/websocket/websocket.dart';
import 'package:acti_mobile/domain/services/map_optimization_service.dart';
import 'package:acti_mobile/presentation/screens/events/screens/events_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/event/widgets/card_event_on_map.dart';
import 'package:acti_mobile/presentation/screens/maps/event/widgets/cascade_cards_event_on_map.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class MapScreen extends StatefulWidget {
  // final int selectedScreenIndex;
  const MapScreen({
    super.key,
  });

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
  String? profileId;

  PointAnnotationManager? pointAnnotationManager;

  final String eventsSourceId = "events-source";
  final String eventsLayerId = "events-layer";
  final String iconImageIdPrefix = "event-icon-";

  MapboxMap? _mapboxMap;
  final _requiredImages = [
    'amusement-park',
    'religious-christian',
    'rail',
    'shop',
    'museum',
  ];

  // Сервис оптимизации карты
  final MapOptimizationService _mapOptimizationService =
      MapOptimizationService();

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
    if (searchedEventsModel == null) return;
    final groups = _groupEventsByLocation(searchedEventsModel!.events);
    List<OrganizedEventModel> tappedEvents = [];
    for (var group in groups) {
      final first = group.first;
      final distance = geolocator.Geolocator.distanceBetween(
        (first.latitude ?? 0.0).toDouble(),
        (first.longitude ?? 0.0).toDouble(),
        context.point.coordinates.lat.toDouble(),
        context.point.coordinates.lng.toDouble(),
      );
      if (distance <= 100) {
        tappedEvents = group;
        break;
      }
    }
    if (tappedEvents.isNotEmpty) {
      if (tappedEvents.length == 1) {
        await Get.bottomSheet(
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            CardEventOnMap(organizedEvent: tappedEvents.first));
      } else {
        await Get.bottomSheet(
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            CascadeCardsEventOnMap(
                organizedEvents: tappedEvents, profileId: profileId ?? ''));
      }
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
    _loadMapImages();
  }

  @override
  void dispose() {
    // TODO: Implement proper cleanup when Mapbox API is updated
    // _mapboxMap?.style.removeStyleImageMissingListener((event) {});
    _deepLinkService?.dispose();
    sheetController.dispose();
    super.dispose();
  }

  void initialize() async {
    setState(() {
      isLoading = true;
    });

    // iOS-специфичные оптимизации
    if (Platform.isIOS) {
      // Устанавливаем более консервативные настройки для iOS
      currentZoom = 14.0; // Уменьшаем зум для iOS
    }

    // Быстрая инициализация сервиса оптимизации карты (без предварительной загрузки)
    await _mapOptimizationService.quickInitialize();

    // Параллельное выполнение независимых операций
    final futures = await Future.wait<dynamic>([
      // Получение токена
      SecureStorageService().getAccessToken(),
      // Проверка разрешения геолокации
      geolocator.Geolocator.checkPermission(),
    ]);

    profileId = await SecureStorageService().getUserId();

    final accessToken = futures[0] as String;
    currentPermission = futures[1] as geolocator.LocationPermission;

    // Запускаем WebSocket в фоне, не блокируя UI
    Future.microtask(() {
      connectToOnlineStatus(accessToken).catchError((e) {
        developer.log('Ошибка при подключении к WebSocket: $e',
            name: 'MAP_SCREEN');
      });
    });

    // Запускаем предварительную загрузку данных карты в фоне
    Future.microtask(() {
      _mapOptimizationService.preloadMapData().catchError((e) {
        developer.log('Ошибка предварительной загрузки карты: $e',
            name: 'MAP_SCREEN');
      });
    });

    if (currentPermission.name == 'denied') {
      currentPermission = await geolocator.Geolocator.requestPermission();
    }

    if (currentPermission.name != 'denied' && await checkGeolocator()) {
      try {
        // iOS-специфичные настройки геолокации
        final locationSettings = Platform.isIOS
            ? geolocator.LocationSettings(
                accuracy: geolocator.LocationAccuracy.high,
                distanceFilter: 10, // 10 метров
                timeLimit: const Duration(seconds: 3),
              )
            : geolocator.LocationSettings(
                accuracy: geolocator.LocationAccuracy.high,
                timeLimit: const Duration(seconds: 3),
              );

        final position = await geolocator.Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );

        // Запускаем обновление локации в фоне
        Future.microtask(() {
          delayedLocationUpdate(position.latitude, position.longitude)
              .catchError((e) {
            developer.log('Ошибка при обновлении локации: $e',
                name: 'MAP_SCREEN');
          });
        });

        // Сохраняем локацию в сервисе оптимизации
        await _mapOptimizationService.saveLastLocation(
            position.latitude, position.longitude);

        setState(() {
          currentUserPosition = Position(position.longitude, position.latitude);
          currentSelectedPosition =
              Position(position.longitude, position.latitude);
        });
      } catch (e) {
        developer.log('Ошибка получения геолокации: $e', name: 'MAP_SCREEN');
        setState(() {
          currentUserPosition = null;
          currentSelectedPosition =
              Position(37.60709779391965, 55.73523399526778);
        });
      }
    } else {
      setState(() {
        currentUserPosition = null;
        currentSelectedPosition =
            Position(37.60709779391965, 55.73523399526778);
      });
    }

    // Инициализация карты
    context.read<ProfileBloc>().add(InitializeMapEvent(
        latitude: currentSelectedPosition.lat.toDouble(),
        longitude: currentSelectedPosition.lng.toDouble()));

    setState(() {
      isLoading = false;
    });
  }

  Future<void> delayedLocationUpdate(double lat, double lon) async {
    MapApi().updateUserLocation(lat, lon);
  }

  Future<void> _loadMapImages() async {
    // TODO: Implement proper image loading when Mapbox API is updated
    // for (final imageId in _requiredImages) {
    //   try {
    //     final ByteData data = await rootBundle.load('assets/images/map/$imageId.png');
    //     final Uint8List bytes = data.buffer.asUint8List();
    //     await _mapboxMap?.style.addStyleImage(
    //       imageId,
    //       bytes,
    //     );
    //   } catch (e) {
    //     print('Error loading image $imageId: $e');
    //   }
    // }
  }

  Future<void> _loadLocalStyle() async {
    try {
      // Проверяем, есть ли кэшированный стиль
      final cachedStyle = _mapOptimizationService.getCachedStyle();

      if (cachedStyle != null && cachedStyle.startsWith('mapbox://')) {
        // Используем кэшированный стиль
        if (_mapboxMap != null) {
          await _mapboxMap!.loadStyleURI(cachedStyle);
          developer.log('Использован кэшированный стиль карты',
              name: 'MAP_SCREEN');
        }
      } else {
        // Загружаем локальный стиль
        final styleJson =
            await rootBundle.loadString('assets/map_styles/custom_style.json');

        final modifiedStyleJson = styleJson.replaceAll(
            'YOUR_MAPBOX_ACCESS_TOKEN',
            'pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg');

        if (_mapboxMap != null) {
          await _mapboxMap!.loadStyleJson(modifiedStyleJson);
          // Кэшируем стиль
          await _mapOptimizationService
              .cacheMapStyle('mapbox://styles/acti/cmbf00t92005701s5d84c1cqp');
        }
      }
    } catch (e) {
      print('Ошибка загрузки локального стиля: $e');
      // Fallback к онлайн стилю
      if (_mapboxMap != null) {
        await _mapboxMap!
            .loadStyleURI('mapbox://styles/acti/cmbf00t92005701s5d84c1cqp');
      }
    }
  }

  // Группировка событий по координатам с точностью до 100 м
  List<List<OrganizedEventModel>> _groupEventsByLocation(
      List<OrganizedEventModel> events) {
    List<List<OrganizedEventModel>> groups = [];
    for (var event in events) {
      bool added = false;
      for (var group in groups) {
        final first = group.first;
        final distance = geolocator.Geolocator.distanceBetween(
          (event.latitude ?? 0.0).toDouble(),
          (event.longitude ?? 0.0).toDouble(),
          (first.latitude ?? 0.0).toDouble(),
          (first.longitude ?? 0.0).toDouble(),
        );
        if (distance <= 100) {
          group.add(event);
          added = true;
          break;
        }
      }
      if (!added) {
        groups.add([event]);
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
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

          if (mapboxMap != null && pointAnnotationManager != null) {
            // Только группировка!
            await pointAnnotationManager!.deleteAll();
            final groups = _groupEventsByLocation(searchedEventsModel!.events);
            for (var group in groups) {
              final avgLat =
                  group.map((e) => e.latitude ?? 0.0).reduce((a, b) => a + b) /
                      group.length;
              final avgLng =
                  group.map((e) => e.longitude ?? 0.0).reduce((a, b) => a + b) /
                      group.length;
              final event = group.first;
              final result = await screenshotController.captureFromWidget(
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CategoryMarker(
                      title: event.category!.name,
                      iconUrl: event.category!.iconPath,
                    ),
                    if (group.length > 1)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ' + ${group.length.toString()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
              await addEventIconFromUrl(
                  mapboxMap!, 'pointer:${event.id}', result);
              final pointAnnotationOptions = PointAnnotationOptions(
                geometry: Point(coordinates: Position(avgLng, avgLat)),
                iconSize: 0.75,
                image: result,
                iconImage: 'pointer:${event.id}',
              );
              await pointAnnotationManager!.create(pointAnnotationOptions);
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
                    MapWidget(
                      onStyleLoadedListener: (styleLoadedEventData) async {
                        if (currentUserPosition != null && mapboxMap != null) {
                          await addUserIconToStyle(mapboxMap!);
                        }
                        if (searchedEventsModel != null &&
                            mapboxMap != null &&
                            pointAnnotationManager != null) {
                          // Только группировка!
                          await pointAnnotationManager!.deleteAll();
                          final groups = _groupEventsByLocation(
                              searchedEventsModel!.events);
                          for (var group in groups) {
                            final avgLat = group
                                    .map((e) => e.latitude ?? 0.0)
                                    .reduce((a, b) => a + b) /
                                group.length;
                            final avgLng = group
                                    .map((e) => e.longitude ?? 0.0)
                                    .reduce((a, b) => a + b) /
                                group.length;
                            final event = group.first;
                            final result =
                                await screenshotController.captureFromWidget(
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  CategoryMarker(
                                    title: event.category!.name,
                                    iconUrl: event.category!.iconPath,
                                  ),
                                  if (group.length > 1)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          ' + ${group.length.toString()}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                            await addEventIconFromUrl(
                                mapboxMap!, 'pointer:${event.id}', result);
                            final pointAnnotationOptions =
                                PointAnnotationOptions(
                              geometry:
                                  Point(coordinates: Position(avgLng, avgLat)),
                              iconSize: 0.75,
                              image: result,
                              iconImage: 'pointer:${event.id}',
                            );
                            await pointAnnotationManager!
                                .create(pointAnnotationOptions);
                          }
                        }
                      },
                      onScrollListener: _onScroll,
                      onTapListener: _onTap,
                      cameraOptions: CameraOptions(
                        zoom: 15.0, // Уменьшаем зум для быстрой загрузки
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: buildMapControls(),
                    ),
                    if (showEvents)
                      DraggableScrollableSheet(
                        controller: sheetController,
                        initialChildSize: 0.8,
                        builder: (context, scrollController) {
                          return EventsHomeListOnMapWidget(
                              scrollController: scrollController);
                        },
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
                      if (pointAnnotationManager != null)
                        pointAnnotationManager!.deleteAll();

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

                      // Добавляем все ограничения из selectedAgeRestrictions
                      restrictions
                          .addAll(filterProvider.selectedAgeRestrictions);

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
                          'Цена: ${filterProvider.isFreeSelected == true ? "Бесплатно" : "${filterProvider.priceMinText} - ${filterProvider.priceMaxText}"}',
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
                              'price_min': filterProvider.isFreeSelected == true
                                  ? 0
                                  : double.tryParse(
                                      filterProvider.priceMinText),
                              'price_max': filterProvider.isFreeSelected == true
                                  ? 0
                                  : double.tryParse(
                                      filterProvider.priceMaxText),
                              'date_from': formattedDateFrom,
                              'date_to': formattedDateTo,
                              'time_from': filterProvider.selectedTimeFrom,
                              'time_to': filterProvider.selectedTimeTo,
                              'type': filterProvider.isOnlineSelected
                                  ? 'online'
                                  : 'offline',
                              'slots_min': filterProvider.slotsMin,
                              'slots_max': filterProvider.slotsMax,
                              'is_organization': filterProvider.isOrganization,
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
      _mapboxMap = mapboxMap;
    });

    // Применяем оптимизированные настройки жестов
    try {
      await mapboxMap.gestures.updateSettings(
          _mapOptimizationService.getOptimizedGesturesSettings());
    } catch (e) {
      developer.log('Ошибка применения оптимизированных настроек жестов: $e',
          name: 'MAP_SCREEN');
    }

    // Загружаем стиль в фоне, не блокируя UI
    Future.microtask(() async {
      await _loadLocalStyle();
    });

    final pointNewAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    setState(() {
      pointAnnotationManager = pointNewAnnotationManager;
    });
    // Удаляем все маркеры при создании карты
    await pointAnnotationManager?.deleteAll();
    // Не рисуем маркеры здесь! Только через onStyleLoadedListener
  }
}
