import 'dart:io';
import 'package:acti_mobile/configs/geolocator_utils.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/domain/api/map/map_api.dart';
import 'package:acti_mobile/domain/deeplinks/deeplinks.dart';
import 'package:acti_mobile/domain/websocket/websocket.dart';
import 'package:acti_mobile/domain/services/map_optimization_service.dart';

import 'package:acti_mobile/presentation/screens/maps/event/widgets/card_event_on_map.dart';
import 'package:acti_mobile/presentation/screens/maps/event/widgets/cascade_cards_event_on_map.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/filter_map_sheet.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'dart:developer' as developer;
import 'package:acti_mobile/main.dart';
import 'package:screenshot/screenshot.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/marker.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/data/models/searched_events_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';

import 'package:acti_mobile/presentation/screens/maps/event/widgets/events_home_map_widget.dart';

import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

import 'package:acti_mobile/presentation/screens/events/providers/filter_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:async';

import 'bloc/map_bloc.dart';
import 'bloc/map_event.dart';
import 'bloc/map_state.dart';

// Порог зума для смены CategoryMarker на GroupedMarker
const double GROUPED_MARKER_MIN_ZOOM = 13.0;

/// Вспомогательный класс для хранения события и его экранных координат
class _EventWithScreen {
  final OrganizedEventModel event;
  final ScreenCoordinate screen;
  _EventWithScreen(this.event, this.screen);
}

// Глобальная переменная для хранения profileId
String? _lastProfileId;

// Класс-обёртка для колбека (top-level)
class _MyPointAnnotationClickListener
    implements OnPointAnnotationClickListener {
  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    onPointAnnotationTap(annotation);
  }
}

// Глобальный обработчик клика по маркеру (top-level)
void onPointAnnotationTap(PointAnnotation annotation) {
  final iconImage = annotation.iconImage;
  if (iconImage == null) return;
  final eventId = iconImage.replaceFirst('pointer:', '');
  final ctx = navigatorKey.currentContext;
  if (ctx == null) return;
  final mapState = BlocProvider.of<MapBloc>(ctx, listen: false).state;
  final group = mapState.groupedEvents.firstWhere(
    (g) => g.any((e) => e.id.toString() == eventId),
    orElse: () => [],
  );
  if (group.isEmpty) return;
  if (group.length > 1) {
    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      CascadeCardsEventOnMap(
        organizedEvents: group,
        profileId: _lastProfileId ?? '',
      ),
    );
  } else {
    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      CardEventOnMap(organizedEvent: group.first),
    );
  }
}

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

  // Анимация для виджета статуса геолокации
  bool _showLocationStatus = true;
  Timer? _locationStatusTimer;
  Timer? _cameraIdleDebounce;
  final List<double> _clusterZoomLevels = [10, 12, 14, 16, 18];
  double? _lastClusterZoomLevel;

  final Map<String, Uint8List> _markerCache = {};

  // Флаг для атомарного обновления маркеров
  bool isMarkersLoading = false;

  // Храним текущие id маркеров
  Set<String> _currentMarkerIds = {};
  // Храним текущие объекты аннотаций
  final Set<PointAnnotation> _currentAnnotations = {};

  Future<void> _onScroll(
    MapContentGestureContext gestureContext,
  ) async {
    if (!mounted) return;
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

  void onMapTap(
    MapContentGestureContext gestureContext,
    BuildContext buildContext,
    String? profileId,
  ) async {
    final mapState = BlocProvider.of<MapBloc>(buildContext).state;
    if (mapState.groupedEvents.isEmpty) {
      print('[DEBUG] onMapTap: groupedEvents is empty');
      return;
    }
    // Теперь обработка маркеров происходит через onPointAnnotationTap
    // Здесь можно оставить обработку только для пустых мест карты, если нужно
    print('[DEBUG] onMapTap: пустое место карты');
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Обновляем позицию при изменении зависимостей (например, при переключении экранов)
    _updateLocationIfNeeded();
  }

  @override
  void dispose() {
    // TODO: Implement proper cleanup when Mapbox API is updated
    // _mapboxMap?.style.removeStyleImageMissingListener((event) {});
    _deepLinkService?.dispose();
    sheetController.dispose();
    _stopLocationStatusTimer(); // Очищаем таймер
    _cameraIdleDebounce?.cancel();
    super.dispose();
  }

  /// Обновление позиции при необходимости
  Future<void> _updateLocationIfNeeded() async {
    // Проверяем, нужно ли обновить позицию (например, если карта была неактивна)
    if (mounted && mapboxMap != null && currentUserPosition == null) {
      developer.log('Обновляем позицию пользователя при активации экрана',
          name: 'MAP_SCREEN');
      await _getUserLocation();
    }
  }

  /// Принудительное обновление позиции пользователя
  Future<void> refreshUserLocation() async {
    if (!mounted) return;

    developer.log('Принудительное обновление позиции пользователя',
        name: 'MAP_SCREEN');

    setState(() {
      isLoading = true;
    });

    try {
      await _getUserLocation();

      // Обновляем камеру к новой позиции
      if (currentUserPosition != null && mapboxMap != null) {
        await _updateCameraToUserLocation(
          currentUserPosition!.lat.toDouble(),
          currentUserPosition!.lng.toDouble(),
        );
      }

      // Запускаем таймер анимации статуса геолокации
      _startLocationStatusTimer();
    } catch (e) {
      developer.log('Ошибка при обновлении позиции: $e', name: 'MAP_SCREEN');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Управление таймером анимации статуса геолокации
  void _startLocationStatusTimer() {
    _locationStatusTimer?.cancel();
    setState(() {
      _showLocationStatus = true;
    });

    // Таймер только если геолокация активна
    if (currentUserPosition != null) {
      _locationStatusTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showLocationStatus = false;
          });
        }
      });
    } else {
      // Если геолокация неактивна, статус всегда видим и не исчезает
      _locationStatusTimer?.cancel();
      setState(() {
        _showLocationStatus = true;
      });
    }
  }

  /// Остановка таймера анимации статуса геолокации
  void _stopLocationStatusTimer() {
    _locationStatusTimer?.cancel();
    _locationStatusTimer = null;
  }

  void initialize() async {
    if (!mounted) return;
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

    // Исправленный запуск WebSocket
    _connectWebSocket(accessToken);

    // Запускаем предварительную загрузку данных карты в фоне
    Future.microtask(() {
      _mapOptimizationService.preloadMapData().catchError((e) {
        developer.log('Ошибка предварительной загрузки карты: $e',
            name: 'MAP_SCREEN');
      });
    });

    // Получаем позицию пользователя с правильной обработкой
    await _getUserLocation();

    // Инициализация карты
    context.read<ProfileBloc>().add(InitializeMapEvent(
        latitude: currentSelectedPosition.lat.toDouble(),
        longitude: currentSelectedPosition.lng.toDouble()));

    setState(() {
      isLoading = false;
    });

    // Запускаем таймер анимации статуса геолокации после инициализации
    _startLocationStatusTimer();
  }

  /// Получение позиции пользователя с правильной обработкой
  Future<void> _getUserLocation() async {
    try {
      if (currentPermission.name == 'denied') {
        currentPermission = await geolocator.Geolocator.requestPermission();
      }

      if (currentPermission.name != 'denied' && await checkGeolocator()) {
        // iOS-специфичные настройки геолокации
        final locationSettings = Platform.isIOS
            ? geolocator.LocationSettings(
                accuracy: geolocator.LocationAccuracy.high,
                distanceFilter: 10, // 10 метров
                timeLimit: const Duration(seconds: 5), // Увеличиваем таймаут
              )
            : geolocator.LocationSettings(
                accuracy: geolocator.LocationAccuracy.high,
                timeLimit: const Duration(seconds: 5), // Увеличиваем таймаут
              );

        final position = await geolocator.Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );

        developer.log(
            'Получена позиция пользователя: ${position.latitude}, ${position.longitude}',
            name: 'MAP_SCREEN');

        // Сохраняем локацию в сервисе оптимизации
        await _mapOptimizationService.saveLastLocation(
            position.latitude, position.longitude);

        if (mounted) {
          setState(() {
            currentUserPosition =
                Position(position.longitude, position.latitude);
            currentSelectedPosition =
                Position(position.longitude, position.latitude);
          });
        }

        // Запускаем таймер анимации статуса геолокации
        _startLocationStatusTimer();

        // Запускаем обновление локации в фоне
        Future.microtask(() {
          delayedLocationUpdate(position.latitude, position.longitude)
              .catchError((e) {
            developer.log('Ошибка при обновлении локации: $e',
                name: 'MAP_SCREEN');
          });
        });

        // Обновляем камеру карты, если карта уже создана
        if (mapboxMap != null && mounted) {
          await _updateCameraToUserLocation(
              position.latitude, position.longitude);
        }
      } else {
        // Если геолокация недоступна, используем кэшированную позицию или Москву
        final lastLocation = await _mapOptimizationService.getLastLocation();
        if (lastLocation != null) {
          developer.log(
              'Используем кэшированную позицию: ${lastLocation['latitude']}, ${lastLocation['longitude']}',
              name: 'MAP_SCREEN');
          if (mounted) {
            setState(() {
              currentUserPosition = Position(
                  lastLocation['longitude'] as double,
                  lastLocation['latitude'] as double);
              currentSelectedPosition = Position(
                  lastLocation['longitude'] as double,
                  lastLocation['latitude'] as double);
            });
          }
        } else {
          // Используем Москву как fallback
          developer.log('Используем позицию по умолчанию (Москва)',
              name: 'MAP_SCREEN');
          if (mounted) {
            setState(() {
              currentUserPosition = null;
              currentSelectedPosition = Position(37.6173, 55.7558);
            });
          }
        }
      }
    } catch (e) {
      developer.log('Ошибка получения геолокации: $e', name: 'MAP_SCREEN');

      // При ошибке используем кэшированную позицию или Москву
      final lastLocation = await _mapOptimizationService.getLastLocation();
      if (lastLocation != null) {
        if (mounted) {
          setState(() {
            currentUserPosition = Position(lastLocation['longitude'] as double,
                lastLocation['latitude'] as double);
            currentSelectedPosition = Position(
                lastLocation['longitude'] as double,
                lastLocation['latitude'] as double);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            currentUserPosition = null;
            currentSelectedPosition = Position(37.6173, 55.7558);
          });
        }
      }
    }
  }

  /// Обновление камеры карты к позиции пользователя
  Future<void> _updateCameraToUserLocation(
      double latitude, double longitude) async {
    if (mapboxMap == null || !mounted) return;

    try {
      await mapboxMap!.setCamera(CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: currentZoom,
      ));
      developer.log('Камера обновлена к позиции пользователя',
          name: 'MAP_SCREEN');
    } catch (e) {
      developer.log('Ошибка обновления камеры: $e', name: 'MAP_SCREEN');
    }
  }

  void _connectWebSocket(String accessToken) async {
    if (accessToken.isEmpty) return;
    try {
      await connectToOnlineStatus(accessToken);
    } catch (e, st) {
      developer.log('Ошибка при подключении к WebSocket: $e',
          name: 'MAP_SCREEN', error: e, stackTrace: st);
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is SearchedEventsOnMapState) {
          setState(() {
            searchedEventsModel = state.searchedEventsModel;
            print(
                '[DEBUG] BlocListener: обновил searchedEventsModel (SearchedEventsOnMapState), events.length = \u001b[35m${searchedEventsModel?.events.length}\u001b[0m');
          });
        } else if (state is InitializeMapState) {
          setState(() {
            searchedEventsModel = state.searchedEventsModel;
            print(
                '[DEBUG] BlocListener: обновил searchedEventsModel (InitializeMapState), events.length = \u001b[35m${searchedEventsModel?.events.length}\u001b[0m');
          });
        }
      },
      child: BlocListener<MapBloc, MapState>(
        listenWhen: (prev, curr) => prev.groupedEvents != curr.groupedEvents,
        listener: (context, mapState) {
          if (!isMarkersLoading &&
              mapState.groupedEvents.isNotEmpty &&
              mapboxMap != null &&
              pointAnnotationManager != null) {
            _drawBlocMarkers(mapState.groupedEvents);
          }
        },
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, mapState) {
            // DEBUG PRINTS
            print(
                '[DEBUG] groupedEvents: \u001b[32m${mapState.groupedEvents.length}\u001b[0m');
            print(
                '[DEBUG] mapboxMap: $mapboxMap, pointAnnotationManager: $pointAnnotationManager');
            return Scaffold(
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
                            onMapIdleListener: (event) async {
                              if (mapboxMap != null) {
                                final camera =
                                    await mapboxMap!.getCameraState();
                                final zoom = camera.zoom;
                                // Удаляем фильтрацию по _clusterZoomLevels
                                context.read<MapBloc>().add(ZoomChanged(zoom));
                              }
                            },
                            onZoomListener: (ctx) {},
                            onCameraChangeListener: (ctx) {},
                            onScrollListener: (ctx) {},
                            onStyleLoadedListener:
                                (styleLoadedEventData) async {
                              if (!mounted) return;
                              if (currentUserPosition != null &&
                                  mapboxMap != null) {
                                await addUserIconToStyle(mapboxMap!);
                              }
                              // DEBUG PRINTS
                              print(
                                  '[DEBUG] onStyleLoadedListener: searchedEventsModel: $searchedEventsModel');
                              if (searchedEventsModel != null) {
                                print(
                                    '[DEBUG] searchedEventsModel.events.length: \u001b[34m${searchedEventsModel!.events.length}\u001b[0m');
                                context.read<MapBloc>().add(
                                    LoadEvents(searchedEventsModel!.events));
                              }
                            },
                            onTapListener: (gestureContext) {
                              print(
                                  '[DEBUG] onTapListener: tap at lat=${gestureContext.point.coordinates.lat}, lng=${gestureContext.point.coordinates.lng}');
                              onMapTap(gestureContext, context, profileId);
                            },
                            cameraOptions: CameraOptions(
                              zoom: 15.0,
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
                          // Отображение текущего зума
                          // Positioned(
                          //   top: 24,
                          //   right: 24,
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(
                          //         horizontal: 12, vertical: 6),
                          //     decoration: BoxDecoration(
                          //       color: Colors.black.withOpacity(0.5),
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //     child: Text(
                          //       'Зум: ${mapState.zoom.toStringAsFixed(2)}',
                          //       style: const TextStyle(
                          //         color: Colors.white,
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          if (isMarkersLoading)
                            // Аккуратный индикатор загрузки маркеров
                            Center(
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          // Виджет статуса геолокации
                          Positioned(
                            top: 50,
                            right: 80,
                            left: 80,
                            child: AnimatedOpacity(
                              opacity: _showLocationStatus ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: GestureDetector(
                                onLongPress: () {
                                  // Долгое нажатие для принудительного обновления позиции
                                  refreshUserLocation();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        currentUserPosition != null
                                            ? Icons.location_on
                                            : Icons.location_off,
                                        size: 16,
                                        color: currentUserPosition != null
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        currentUserPosition != null
                                            ? 'Геолокация активна'
                                            : 'Геолокация недоступна',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
            );
          },
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
                  builder: (context) => FilterMapSheet(
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
                  final updatedCamera = await mapboxMap!.getCameraState();
                  setState(() {
                    currentZoom = updatedCamera.zoom;
                  });
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
                  final updatedCamera = await mapboxMap!.getCameraState();
                  setState(() {
                    currentZoom = updatedCamera.zoom;
                  });
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
                  // Показываем статус только если геолокация активна
                  _startLocationStatusTimer();
                } else {
                  // Если позиция не определена, пытаемся получить её заново
                  developer.log(
                      'Позиция пользователя не определена, получаем заново',
                      name: 'MAP_SCREEN');
                  await _getUserLocation();

                  // Если после обновления позиция определена, перемещаем камеру и показываем статус
                  if (currentUserPosition != null && mapboxMap != null) {
                    await mapboxMap!.setCamera(CameraOptions(
                        center: Point(
                            coordinates: Position(currentUserPosition!.lng,
                                currentUserPosition!.lat)),
                        zoom: currentZoom));
                    _startLocationStatusTimer();
                  } else {
                    // Если всё ещё не удалось получить позицию, показываем сообщение и явно показываем статус "недоступна"
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Не удалось определить вашу позицию. Проверьте настройки геолокации.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      setState(() {
                        _showLocationStatus = true;
                      });
                    }
                  }
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
    if (!mounted) return;
    setState(() {
      this.mapboxMap = mapboxMap;
      _mapboxMap = mapboxMap;
    });
    context.read<MapBloc>().setMapbox(mapboxMap);
    print('[DEBUG] MapScreen: mapboxMap передан в MapBloc');

    // Сохраняем profileId глобально для обработчика
    _lastProfileId = profileId;

    // Применяем оптимизированные настройки жестов
    try {
      await mapboxMap.gestures.updateSettings(
          _mapOptimizationService.getOptimizedGesturesSettings());
    } catch (e) {
      developer.log('Ошибка применения оптимизированных настроек жестов: $e',
          name: 'MAP_SCREEN');
    }

    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await mapboxMap.logo.updateSettings(LogoSettings(enabled: true));
    await mapboxMap.attribution
        .updateSettings(AttributionSettings(enabled: true));
    await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));

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

    // Регистрируем обработчик нажатия на маркеры
    pointAnnotationManager
        ?.addOnPointAnnotationClickListener(_MyPointAnnotationClickListener());
  }

  // Вспомогательная функция для выбора типа маркера группы
  Widget _buildGroupMarker(int groupLength, double zoom) {
    if (groupLength > 1 && zoom < 12) {
      return CircleCountMarker(count: groupLength);
    } else {
      return GroupedMarker(count: groupLength);
    }
  }

  // Вспомогательная функция для выбора типа маркера события/группы
  Widget _buildMarker(List<OrganizedEventModel> group, double zoom) {
    if (group.length > 1) {
      // Для групп: при сильном отдалении — круг, иначе GroupedMarker
      if (zoom < 12) {
        return CircleCountMarker(count: group.length);
      } else {
        return GroupedMarker(count: group.length);
      }
    } else {
      // Для одиночных событий: всегда CategoryMarker
      final event = group.first;
      return CategoryMarker(
        title: event.category!.name,
        iconUrl: event.category!.iconPath,
      );
    }
  }

  // Новый метод для эффективного обновления маркеров по состоянию Bloc
  Future<void> _drawBlocMarkers(List<List<OrganizedEventModel>> groups) async {
    print(
        '[DEBUG] _drawBlocMarkers вызван, групп: \u001b[33m${groups.length}\u001b[0m');
    if (mapboxMap == null || pointAnnotationManager == null) return;
    setState(() {
      isMarkersLoading = true;
    });
    final mapState = BlocProvider.of<MapBloc>(context, listen: false).state;
    final double zoom = mapState.zoom;
    final Set<String> newMarkerIds =
        groups.map((g) => 'pointer:${g.first.id}').toSet();
    final Map<String, List<OrganizedEventModel>> groupById = {
      for (var g in groups) 'pointer:${g.first.id}': g
    };

    // 1. Удаляем только те маркеры, которых больше нет
    final toRemove = _currentMarkerIds.difference(newMarkerIds);
    print('[DEBUG] Маркеры к удалению: ${toRemove.length}');
    if (toRemove.isNotEmpty) {
      final toRemoveAnnotations = _currentAnnotations
          .where((a) => toRemove.contains(a.iconImage))
          .toList();
      for (final annotation in toRemoveAnnotations) {
        await pointAnnotationManager!.delete(annotation);
        _currentAnnotations.remove(annotation);
      }
    }

    // 2. Добавляем только новые маркеры
    final toAdd = newMarkerIds.difference(_currentMarkerIds);
    print('[DEBUG] Маркеры к добавлению: ${toAdd.length}');
    for (final id in toAdd) {
      final group = groupById[id]!;
      final avgLat =
          group.map((e) => e.latitude ?? 0.0).reduce((a, b) => a + b) /
              group.length;
      final avgLng =
          group.map((e) => e.longitude ?? 0.0).reduce((a, b) => a + b) /
              group.length;
      print(
          '[DEBUG] Добавляю маркер: id=$id, groupSize=${group.length}, avgLat=$avgLat, avgLng=$avgLng');
      final event = group.first;
      try {
        final cacheKey =
            '${event.id}_${group.length}_${zoom.toStringAsFixed(1)}';
        Uint8List result;
        if (_markerCache.containsKey(cacheKey)) {
          result = _markerCache[cacheKey]!;
        } else {
          result = await screenshotController.captureFromWidget(
            Stack(
              alignment: Alignment.center,
              children: [
                _buildMarker(group, zoom),
              ],
            ),
          );
          _markerCache[cacheKey] = result;
        }
        await addEventIconFromUrl(mapboxMap!, id, result);
        final pointAnnotationOptions = PointAnnotationOptions(
          geometry: Point(coordinates: Position(avgLng, avgLat)),
          iconSize: 0.75,
          image: result,
          iconImage: id,
        );
        final annotation =
            await pointAnnotationManager!.create(pointAnnotationOptions);
        _currentAnnotations.add(annotation);
        print('[DEBUG] Маркер успешно добавлен: $id');
      } catch (e, st) {
        print('[ERROR] draw marker: $e\n$st');
      }
    }

    // 3. Обновляем список текущих id
    _currentMarkerIds = newMarkerIds;
    setState(() {
      isMarkersLoading = false;
    });
    print(
        '[DEBUG] Маркеры обновлены: всего сейчас ${_currentMarkerIds.length}');
  }
}

class CircleCountMarker extends StatelessWidget {
  final int count;
  const CircleCountMarker({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        color: Colors.green,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
