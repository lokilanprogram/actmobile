// import 'dart:io';
// import 'package:acti_mobile/configs/geolocator_utils.dart';
// import 'package:acti_mobile/configs/storage.dart';
// import 'package:acti_mobile/data/models/profile_event_model.dart';
// import 'package:acti_mobile/domain/api/map/map_api.dart';
// // import 'package:acti_mobile/domain/deeplinks/deeplinks.dart';
// import 'package:acti_mobile/domain/websocket/websocket.dart';
// import 'package:acti_mobile/domain/services/map_optimization_service.dart';

// import 'package:acti_mobile/presentation/screens/maps/event/widgets/card_event_on_map.dart';
// import 'package:acti_mobile/presentation/screens/maps/event/widgets/cascade_cards_event_on_map.dart';
// import 'package:acti_mobile/presentation/screens/maps/map/widgets/filter_map_sheet.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'dart:ui';
// import 'dart:developer' as developer;
// import 'package:acti_mobile/main.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:acti_mobile/presentation/screens/maps/map/widgets/marker.dart';
// import 'package:widgets_to_image/widgets_to_image.dart';
// import 'package:acti_mobile/configs/colors.dart';
// import 'package:acti_mobile/configs/function.dart';
// import 'package:acti_mobile/data/models/searched_events_model.dart';
// import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
// import 'package:acti_mobile/presentation/screens/chats/chat_main/chat_main_screen.dart';
// import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
// import 'package:acti_mobile/presentation/screens/maps/event/widgets/events_home_map_widget.dart';
// import 'package:acti_mobile/presentation/screens/profile/my_events/get/my_events_screen.dart';
// import 'package:acti_mobile/presentation/screens/profile/profile_menu/profile_menu_screen.dart';
// import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart' as geolocator;
// import 'package:acti_mobile/presentation/screens/events/widgets/filter_bottom_sheet.dart';
// import 'package:acti_mobile/presentation/screens/events/providers/filter_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'dart:typed_data';
// import 'dart:async';
// import 'dart:math' as math;
// import 'bloc/map_bloc.dart';
// import 'bloc/map_event.dart';
// import 'bloc/map_state.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// // Порог зума для смены CategoryMarker на GroupedMarker
// const double GROUPED_MARKER_MIN_ZOOM = 13.0;

// // Порог зума для смены маркеров на синие точки
// const double SIMPLE_POINT_MIN_ZOOM = 11.0;

// /// Вспомогательный класс для хранения события и его экранных координат
// class _EventWithScreen {
//   final OrganizedEventModel event;
//   final ScreenCoordinate screen;
//   _EventWithScreen(this.event, this.screen);
// }

// // Глобальная переменная для хранения profileId
// String? _lastProfileId;

// // Флаг для предотвращения двойного клика (статический для глобального доступа)
// bool _isProcessingTap = false;

// // Класс-обёртка для колбека (top-level)
// class _MyPointAnnotationClickListener
//     implements OnPointAnnotationClickListener {
//   @override
//   void onPointAnnotationClick(PointAnnotation annotation) {
//     onPointAnnotationTap(annotation);
//   }
// }

// // Глобальный обработчик клика по маркеру (top-level)
// void onPointAnnotationTap(PointAnnotation annotation) {
//   // Защита от двойного клика
//   if (_isProcessingTap) {
//     print('[DEBUG] Игнорируем двойной клик по маркеру');
//     return;
//   }

//   _isProcessingTap = true;

//   try {
//     final iconImage = annotation.iconImage;
//     if (iconImage == null) {
//       print('[DEBUG] iconImage is null, пропускаем обработку');
//       return;
//     }

//     final eventId = iconImage.replaceFirst('pointer:', '');
//     print('[DEBUG] Обрабатываем клик по маркеру события: $eventId');

//     final ctx = navigatorKey.currentContext;
//     if (ctx == null) {
//       print('[DEBUG] Context is null, пропускаем обработку');
//       return;
//     }

//     final mapState = BlocProvider.of<MapBloc>(ctx, listen: false).state;
//     final group = mapState.groupedEvents.firstWhere(
//       (g) => g.any((e) => e.id.toString() == eventId),
//       orElse: () => [],
//     );

//     if (group.isEmpty) {
//       print('[DEBUG] Группа событий не найдена для ID: $eventId');
//       return;
//     }

//     print('[DEBUG] Найдена группа из ${group.length} событий');

//     // Проверяем, не открыто ли уже модальное окно
//     if (Navigator.of(ctx).canPop()) {
//       print('[DEBUG] Модальное окно уже открыто, пропускаем открытие нового');
//       return;
//     }

//     if (group.length > 1) {
//       print('[DEBUG] Открываем CascadeCardsEventOnMap для группы событий');
//       showModalBottomSheet(
//         context: ctx,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (context) => CascadeCardsEventOnMap(
//           organizedEvents: group,
//           profileId: _lastProfileId ?? '',
//         ),
//       ).then((_) {
//         // Сбрасываем флаг при закрытии модального окна
//         _isProcessingTap = false;
//         print(
//             '[DEBUG] Модальное окно CascadeCardsEventOnMap закрыто, флаг сброшен');
//       });
//     } else {
//       print('[DEBUG] Открываем CardEventOnMap для одиночного события');
//       showModalBottomSheet(
//         context: ctx,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (context) => CardEventOnMap(organizedEvent: group.first),
//       ).then((_) {
//         // Сбрасываем флаг при закрытии модального окна
//         _isProcessingTap = false;
//         print('[DEBUG] Модальное окно CardEventOnMap закрыто, флаг сброшен');
//       });
//     }
//   } catch (e) {
//     print('[ERROR] Ошибка при обработке клика по маркеру: $e');
//     // Сбрасываем флаг в случае ошибки
//     _isProcessingTap = false;
//   }
//   // Убираем finally блок, так как флаг сбрасывается при закрытии модального окна
// }

// class MapScreen extends StatefulWidget {
//   // final int selectedScreenIndex;
//   const MapScreen({
//     super.key,
//   });

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   WidgetsToImageController controller = WidgetsToImageController();
//   ScreenshotController screenshotController = ScreenshotController();
//   int selectedIndex = 0;
//   MapboxMap? mapboxMap;
//   late geolocator.LocationPermission currentPermission;
//   Position currentSelectedPosition = Position(37.6173, 55.7558); // Москва
//   Position? currentUserPosition;
//   double currentZoom = 16;
//   bool isLoading = false;
//   bool showEvents = false;
//   bool showSettings = false;
//   // DeepLinkService? _deepLinkService;
//   DraggableScrollableController sheetController =
//       DraggableScrollableController();
//   SearchedEventsModel? searchedEventsModel;
//   String? profileId;

//   // Последняя позиция, с которой был отправлен запрос
//   Position? _lastRequestPosition;

//   PointAnnotationManager? pointAnnotationManager;

//   final String eventsSourceId = "events-source";
//   final String eventsLayerId = "events-layer";
//   final String iconImageIdPrefix = "event-icon-";

//   MapboxMap? _mapboxMap;
//   final _requiredImages = [
//     'amusement-park',
//     'religious-christian',
//     'rail',
//     'shop',
//     'museum',
//   ];

//   // Сервис оптимизации карты
//   final MapOptimizationService _mapOptimizationService =
//       MapOptimizationService();

//   // Анимация для виджета статуса геолокации
//   bool _showLocationStatus = true;
//   Timer? _locationStatusTimer;
//   Timer? _cameraIdleDebounce;
//   final List<double> _clusterZoomLevels = [10, 12, 14, 16, 18];
//   double? _lastClusterZoomLevel;

//   final Map<String, Uint8List> _markerCache = {};

//   // Флаг для атомарного обновления маркеров
//   bool isMarkersLoading = false;

//   // Кэш уже добавленных маркеров на карте
//   final Set<String> _addedMarkerIds = {};

//   // Очередь событий, которые пришли до инициализации карты
//   MapState? _pendingMapState;

//   // Кэш предварительно созданных изображений для каждого типа маркеров
//   final Map<String, Uint8List> _prebuiltMarkerImages = {};

//   // Кэш изображений категорий для ускорения загрузки
//   final Map<String, Uint8List> _categoryImageCache = {};

//   // Кэш готовых маркеров категорий
//   final Map<String, Uint8List> _categoryMarkerCache = {};

//   // Флаг для отслеживания регистрации обработчика клика
//   bool _isClickListenerRegistered = false;

//   Future<void> _onScroll(
//     MapContentGestureContext gestureContext,
//   ) async {
//     if (!mounted) return;
//     double distance = geolocator.Geolocator.distanceBetween(
//       currentSelectedPosition.lat.toDouble(),
//       currentSelectedPosition.lng.toDouble(),
//       gestureContext.point.coordinates.lat.toDouble(),
//       gestureContext.point.coordinates.lng.toDouble(),
//     );

//     if (distance > 100000) {
//       print('more than 100 km');
//       setState(() {
//         currentSelectedPosition = Position(
//             gestureContext.point.coordinates.lng.toDouble(),
//             gestureContext.point.coordinates.lat.toDouble());
//       });
//       context.read<ProfileBloc>().add(SearchEventsOnMapEvent(
//           latitude: gestureContext.point.coordinates.lat.toDouble(),
//           longitude: gestureContext.point.coordinates.lng.toDouble()));
//     }
//   }

//   /// Обработка перемещения камеры и отправка запроса с новыми координатами
//   Future<void> _onCameraMove(CameraState cameraState) async {
//     if (!mounted) return;

//     final newLat = cameraState.center.coordinates.lat.toDouble();
//     final newLng = cameraState.center.coordinates.lng.toDouble();

//     // Вычисляем расстояние от текущей позиции
//     double distance = geolocator.Geolocator.distanceBetween(
//       currentSelectedPosition.lat.toDouble(),
//       currentSelectedPosition.lng.toDouble(),
//       newLat,
//       newLng,
//     );

//     // Если перемещение больше 1 км, проверяем расстояние от последнего запроса
//     if (distance > 1000) {
//       // Если есть последняя позиция запроса, проверяем расстояние от неё
//       if (_lastRequestPosition != null) {
//         double distanceFromLastRequest = geolocator.Geolocator.distanceBetween(
//           _lastRequestPosition!.lat.toDouble(),
//           _lastRequestPosition!.lng.toDouble(),
//           newLat,
//           newLng,
//         );

//         // Если расстояние от последнего запроса меньше 50 км, пропускаем
//         if (distanceFromLastRequest < 50000) {
//           print(
//               '[DEBUG] Расстояние от последнего запроса ${distanceFromLastRequest.toStringAsFixed(0)}м < 50км, пропускаем запрос');
//           setState(() {
//             currentSelectedPosition = Position(newLng, newLat);
//           });
//           return;
//         }
//       }

//       print(
//           '[DEBUG] Камера переместилась на ${distance.toStringAsFixed(0)}м, обновляем события');
//       setState(() {
//         currentSelectedPosition = Position(newLng, newLat);
//         _lastRequestPosition = Position(newLng, newLat);
//       });

//       // Очищаем кэш событий в MapBloc при смене области
//       context.read<MapBloc>().add(const UpdateMarkers());

//       // Отправляем запрос с новыми координатами
//       context.read<ProfileBloc>().add(SearchEventsOnMapEvent(
//             latitude: newLat,
//             longitude: newLng,
//           ));
//     }
//   }

//   void onMapTap(
//     MapContentGestureContext gestureContext,
//     BuildContext buildContext,
//     String? profileId,
//   ) async {
//     // Если обрабатывается клик по маркеру, игнорируем клик по карте
//     if (_isProcessingTap) {
//       print(
//           '[DEBUG] onMapTap: игнорируем клик по карте, так как обрабатывается клик по маркеру');
//       return;
//     }

//     final mapState = BlocProvider.of<MapBloc>(buildContext).state;
//     if (mapState.groupedEvents.isEmpty) {
//       print('[DEBUG] onMapTap: groupedEvents is empty');
//       return;
//     }
//     // Теперь обработка маркеров происходит через onPointAnnotationTap
//     // Здесь можно оставить обработку только для пустых мест карты, если нужно
//     print('[DEBUG] onMapTap: пустое место карты');
//   }

//   @override
//   void initState() {
//     super.initState();
//     initialize();
//     sheetController.addListener(() async {
//       if (sheetController.size <= 0.5) {
//         setState(() {
//           showEvents = false;
//         });
//       }
//       // _deepLinkService!.dispose();
//     });
//     _loadMapImages();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Обновляем позицию при изменении зависимостей (например, при переключении экранов)
//     _updateLocationIfNeeded();
//   }

//   @override
//   void dispose() {
//     // TODO: Implement proper cleanup when Mapbox API is updated
//     // _mapboxMap?.style.removeStyleImageMissingListener((event) {});
//     // _deepLinkService?.dispose();
//     sheetController.dispose();
//     _stopLocationStatusTimer(); // Очищаем таймер
//     _cameraIdleDebounce?.cancel();
//     super.dispose();
//   }

//   /// Обновление позиции при необходимости
//   Future<void> _updateLocationIfNeeded() async {
//     // Проверяем, нужно ли обновить позицию (например, если карта была неактивна)
//     if (mounted && mapboxMap != null && currentUserPosition == null) {
//       developer.log('Обновляем позицию пользователя при активации экрана',
//           name: 'MAP_SCREEN');
//       await _getUserLocation();
//     }
//   }

//   /// Принудительное обновление позиции пользователя
//   Future<void> refreshUserLocation() async {
//     if (!mounted) return;

//     developer.log('Принудительное обновление позиции пользователя',
//         name: 'MAP_SCREEN');

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await _getUserLocation();

//       // Обновляем камеру к новой позиции
//       if (currentUserPosition != null && mapboxMap != null) {
//         await _updateCameraToUserLocation(
//           currentUserPosition!.lat.toDouble(),
//           currentUserPosition!.lng.toDouble(),
//         );
//       }

//       // Запускаем таймер анимации статуса геолокации
//       _startLocationStatusTimer();
//     } catch (e) {
//       developer.log('Ошибка при обновлении позиции: $e', name: 'MAP_SCREEN');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   /// Управление таймером анимации статуса геолокации
//   void _startLocationStatusTimer() {
//     _locationStatusTimer?.cancel();
//     setState(() {
//       _showLocationStatus = true;
//     });

//     // Таймер только если геолокация активна
//     if (currentUserPosition != null) {
//       _locationStatusTimer = Timer(const Duration(seconds: 3), () {
//         if (mounted) {
//           setState(() {
//             _showLocationStatus = false;
//           });
//         }
//       });
//     } else {
//       // Если геолокация неактивна, статус всегда видим и не исчезает
//       _locationStatusTimer?.cancel();
//       setState(() {
//         _showLocationStatus = true;
//       });
//     }
//   }

//   /// Остановка таймера анимации статуса геолокации
//   void _stopLocationStatusTimer() {
//     _locationStatusTimer?.cancel();
//     _locationStatusTimer = null;
//   }

//   void initialize() async {
//     if (!mounted) return;
//     setState(() {
//       isLoading = true;
//     });

//     // iOS-специфичные оптимизации
//     if (Platform.isIOS) {
//       // Устанавливаем более консервативные настройки для iOS
//       currentZoom = 14.0; // Уменьшаем зум для iOS
//     }

//     // Быстрая инициализация сервиса оптимизации карты (без предварительной загрузки)
//     await _mapOptimizationService.quickInitialize();

//     // Предварительная загрузка изображений маркеров в фоне
//     Future.microtask(() {
//       _preloadMarkerImages().catchError((e) {
//         developer.log(
//             'Ошибка предварительной загрузки изображений маркеров: $e',
//             name: 'MAP_SCREEN');
//       });
//     });

//     // Параллельное выполнение независимых операций
//     final futures = await Future.wait<dynamic>([
//       // Получение токена
//       SecureStorageService().getAccessToken(),
//       // Проверка разрешения геолокации
//       geolocator.Geolocator.checkPermission(),
//     ]);

//     profileId = await SecureStorageService().getUserId();

//     final accessToken = futures[0] as String;
//     currentPermission = futures[1] as geolocator.LocationPermission;

//     // Исправленный запуск WebSocket
//     _connectWebSocket(accessToken);

//     // Запускаем предварительную загрузку данных карты в фоне
//     Future.microtask(() {
//       _mapOptimizationService.preloadMapData().catchError((e) {
//         developer.log('Ошибка предварительной загрузки карты: $e',
//             name: 'MAP_SCREEN');
//       });
//     });

//     // Получаем позицию пользователя с правильной обработкой
//     await _getUserLocation();

//     // Инициализация карты
//     context.read<ProfileBloc>().add(InitializeMapEvent(
//         latitude: currentSelectedPosition.lat.toDouble(),
//         longitude: currentSelectedPosition.lng.toDouble()));

//     // Устанавливаем начальную позицию запроса
//     _lastRequestPosition = currentSelectedPosition;

//     setState(() {
//       isLoading = false;
//     });

//     // Запускаем таймер анимации статуса геолокации после инициализации
//     _startLocationStatusTimer();
//   }

//   /// Получение позиции пользователя с правильной обработкой
//   Future<void> _getUserLocation() async {
//     try {
//       if (currentPermission.name == 'denied') {
//         currentPermission = await geolocator.Geolocator.requestPermission();
//       }

//       if (currentPermission.name != 'denied' && await checkGeolocator()) {
//         // iOS-специфичные настройки геолокации
//         final locationSettings = Platform.isIOS
//             ? geolocator.LocationSettings(
//                 accuracy: geolocator.LocationAccuracy.high,
//                 distanceFilter: 10, // 10 метров
//                 timeLimit: const Duration(seconds: 5), // Увеличиваем таймаут
//               )
//             : geolocator.LocationSettings(
//                 accuracy: geolocator.LocationAccuracy.high,
//                 timeLimit: const Duration(seconds: 5), // Увеличиваем таймаут
//               );

//         final position = await geolocator.Geolocator.getCurrentPosition(
//           locationSettings: locationSettings,
//         );

//         developer.log(
//             'Получена позиция пользователя: ${position.latitude}, ${position.longitude}',
//             name: 'MAP_SCREEN');

//         // Сохраняем локацию в сервисе оптимизации
//         await _mapOptimizationService.saveLastLocation(
//             position.latitude, position.longitude);

//         if (mounted) {
//           setState(() {
//             currentUserPosition =
//                 Position(position.longitude, position.latitude);
//             currentSelectedPosition =
//                 Position(position.longitude, position.latitude);
//             _lastRequestPosition =
//                 Position(position.longitude, position.latitude);
//           });
//         }

//         // Запускаем таймер анимации статуса геолокации
//         _startLocationStatusTimer();

//         // Запускаем обновление локации в фоне
//         Future.microtask(() {
//           delayedLocationUpdate(position.latitude, position.longitude)
//               .catchError((e) {
//             developer.log('Ошибка при обновлении локации: $e',
//                 name: 'MAP_SCREEN');
//           });
//         });

//         // Обновляем камеру карты, если карта уже создана
//         if (mapboxMap != null && mounted) {
//           await _updateCameraToUserLocation(
//               position.latitude, position.longitude);
//         }
//       } else {
//         // Если геолокация недоступна, используем кэшированную позицию или Москву
//         final lastLocation = await _mapOptimizationService.getLastLocation();
//         if (lastLocation != null) {
//           developer.log(
//               'Используем кэшированную позицию: ${lastLocation['latitude']}, ${lastLocation['longitude']}',
//               name: 'MAP_SCREEN');
//           if (mounted) {
//             setState(() {
//               currentUserPosition = Position(
//                   lastLocation['longitude'] as double,
//                   lastLocation['latitude'] as double);
//               currentSelectedPosition = Position(
//                   lastLocation['longitude'] as double,
//                   lastLocation['latitude'] as double);
//             });
//           }
//         } else {
//           // Используем Москву как fallback
//           developer.log('Используем позицию по умолчанию (Москва)',
//               name: 'MAP_SCREEN');
//           if (mounted) {
//             setState(() {
//               currentUserPosition = null;
//               currentSelectedPosition = Position(37.6173, 55.7558);
//             });
//           }
//         }
//       }
//     } catch (e) {
//       developer.log('Ошибка получения геолокации: $e', name: 'MAP_SCREEN');

//       // При ошибке используем кэшированную позицию или Москву
//       final lastLocation = await _mapOptimizationService.getLastLocation();
//       if (lastLocation != null) {
//         if (mounted) {
//           setState(() {
//             currentUserPosition = Position(lastLocation['longitude'] as double,
//                 lastLocation['latitude'] as double);
//             currentSelectedPosition = Position(
//                 lastLocation['longitude'] as double,
//                 lastLocation['latitude'] as double);
//           });
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             currentUserPosition = null;
//             currentSelectedPosition = Position(37.6173, 55.7558);
//           });
//         }
//       }
//     }
//   }

//   /// Обновление камеры карты к позиции пользователя
//   Future<void> _updateCameraToUserLocation(
//       double latitude, double longitude) async {
//     if (mapboxMap == null || !mounted) return;

//     try {
//       await mapboxMap!.setCamera(CameraOptions(
//         center: Point(coordinates: Position(longitude, latitude)),
//         zoom: currentZoom,
//       ));
//       developer.log('Камера обновлена к позиции пользователя',
//           name: 'MAP_SCREEN');
//     } catch (e) {
//       developer.log('Ошибка обновления камеры: $e', name: 'MAP_SCREEN');
//     }
//   }

//   void _connectWebSocket(String accessToken) async {
//     if (accessToken.isEmpty) return;
//     try {
//       await connectToOnlineStatus(accessToken);
//     } catch (e, st) {
//       developer.log('Ошибка при подключении к WebSocket: $e',
//           name: 'MAP_SCREEN', error: e, stackTrace: st);
//     }
//   }

//   Future<void> delayedLocationUpdate(double lat, double lon) async {
//     MapApi().updateUserLocation(lat, lon);
//   }

//   Future<void> _loadMapImages() async {
//     // TODO: Implement proper image loading when Mapbox API is updated
//     // for (final imageId in _requiredImages) {
//     //   try {
//     //     final ByteData data = await rootBundle.load('assets/images/map/$imageId.png');
//     //     final Uint8List bytes = data.buffer.asUint8List();
//     //     await _mapboxMap?.style.addStyleImage(
//     //       imageId,
//     //       bytes,
//     //     );
//     //   } catch (e) {
//     //     print('Error loading image $imageId: $e');
//     //   }
//     // }
//   }

//   Future<void> _loadLocalStyle() async {
//     try {
//       // Проверяем, есть ли кэшированный стиль
//       final cachedStyle = _mapOptimizationService.getCachedStyle();

//       if (cachedStyle != null && cachedStyle.startsWith('mapbox://')) {
//         // Используем кэшированный стиль
//         if (_mapboxMap != null) {
//           await _mapboxMap!.loadStyleURI(cachedStyle);
//           developer.log('Использован кэшированный стиль карты',
//               name: 'MAP_SCREEN');
//         }
//       } else {
//         // Загружаем локальный стиль
//         final styleJson =
//             await rootBundle.loadString('assets/map_styles/custom_style.json');

//         final modifiedStyleJson = styleJson.replaceAll(
//             'YOUR_MAPBOX_ACCESS_TOKEN',
//             'pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg');

//         if (_mapboxMap != null) {
//           await _mapboxMap!.loadStyleJson(modifiedStyleJson);
//           // Кэшируем стиль
//           await _mapOptimizationService
//               .cacheMapStyle('mapbox://styles/acti/cmbf00t92005701s5d84c1cqp');
//         }
//       }
//     } catch (e) {
//       print('Ошибка загрузки локального стиля: $e');
//       // Fallback к онлайн стилю
//       if (_mapboxMap != null) {
//         await _mapboxMap!
//             .loadStyleURI('mapbox://styles/acti/cmbf00t92005701s5d84c1cqp');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<ProfileBloc, ProfileState>(
//       listener: (context, state) {
//         if (state is SearchedEventsOnMapState) {
//           setState(() {
//             searchedEventsModel = state.searchedEventsModel;
//             print(
//                 '[DEBUG] BlocListener: обновил searchedEventsModel (SearchedEventsOnMapState), events.length = \u001b[35m${searchedEventsModel?.events.length}\u001b[0m');
//           });
//           // Обновляем маркеры при получении новых данных
//           if (searchedEventsModel != null) {
//             // Предварительно загружаем изображения категорий
//             _preloadCategoryImages(searchedEventsModel!.events);
//             // Создаем кэш готовых маркеров категорий
//             _createCategoryMarkerCache(searchedEventsModel!.events);
//             context
//                 .read<MapBloc>()
//                 .add(LoadEvents(searchedEventsModel!.events));
//           }
//         } else if (state is InitializeMapState) {
//           setState(() {
//             searchedEventsModel = state.searchedEventsModel;
//             print(
//                 '[DEBUG] BlocListener: обновил searchedEventsModel (InitializeMapState), events.length = \u001b[35m${searchedEventsModel?.events.length}\u001b[0m');
//           });
//           // Обновляем маркеры при инициализации
//           if (searchedEventsModel != null) {
//             // Предварительно загружаем изображения категорий
//             _preloadCategoryImages(searchedEventsModel!.events);
//             // Создаем кэш готовых маркеров категорий
//             _createCategoryMarkerCache(searchedEventsModel!.events);
//             context
//                 .read<MapBloc>()
//                 .add(LoadEvents(searchedEventsModel!.events));
//           }
//         }
//       },
//       child: BlocListener<MapBloc, MapState>(
//         listenWhen: (prev, curr) =>
//             prev.groupedEvents != curr.groupedEvents ||
//             prev.markerType != curr.markerType,
//         listener: (context, mapState) {
//           print('[DEBUG] ===== BlocListener сработал =====');
//           print('[DEBUG] isMarkersLoading: $isMarkersLoading');
//           print(
//               '[DEBUG] groupedEvents.length: ${mapState.groupedEvents.length}');
//           print('[DEBUG] mapboxMap: ${mapboxMap != null}');
//           print(
//               '[DEBUG] pointAnnotationManager: ${pointAnnotationManager != null}');
//           print('[DEBUG] Новых событий: ${mapState.newEventIds.length}');
//           print(
//               '[DEBUG] Событий для удаления: ${mapState.removedEventIds.length}');
//           print('[DEBUG] Тип маркеров: ${mapState.markerType}');

//           if (!isMarkersLoading &&
//               mapState.groupedEvents.isNotEmpty &&
//               mapboxMap != null &&
//               pointAnnotationManager != null) {
//             // Если изменился только тип маркеров (нет новых событий), используем быстрое переключение
//             if (mapState.newEventIds.isEmpty &&
//                 mapState.removedEventIds.isEmpty &&
//                 _addedMarkerIds.isNotEmpty) {
//               print('[DEBUG] Быстрое переключение типа маркеров');
//               _fastSwitchMarkerType(mapState.markerType);
//             } else {
//               print('[DEBUG] Обычная обработка изменений маркеров');
//               // Обрабатываем изменения маркеров
//               _handleMarkerChanges(mapState);
//             }
//           } else if (mapState.groupedEvents.isNotEmpty &&
//               (mapboxMap == null || pointAnnotationManager == null)) {
//             print('[DEBUG] Карта не готова, сохраняем события в очередь');
//             _pendingMapState = mapState;
//           } else {
//             print('[DEBUG] Условия НЕ выполнены, отрисовка пропущена');
//           }
//           print('[DEBUG] ===== КОНЕЦ BlocListener =====');
//         },
//         child: BlocBuilder<MapBloc, MapState>(
//           builder: (context, mapState) {
//             // DEBUG PRINTS
//             print(
//                 '[DEBUG] groupedEvents: \u001b[32m${mapState.groupedEvents.length}\u001b[0m');
//             print(
//                 '[DEBUG] mapboxMap: $mapboxMap, pointAnnotationManager: $pointAnnotationManager');
//             return SafeArea(
//               top: false,
//               child: Scaffold(
//                 backgroundColor: Colors.white,
//                 resizeToAvoidBottomInset: false,
//                 body: WillPopScope(
//                   onWillPop: () async {
//                     SystemNavigator.pop();
//                     return false;
//                   },
//                   child: isLoading
//                       ? const LoaderWidget()
//                       : Stack(
//                           children: [
//                             MapWidget(
//                               onMapIdleListener: (event) async {
//                                 if (mapboxMap != null) {
//                                   final camera =
//                                       await mapboxMap!.getCameraState();
//                                   final zoom = camera.zoom;
//                                   // Находим ближайший ключевой уровень
//                                   final clusterZoom =
//                                       _clusterZoomLevels.lastWhere(
//                                     (z) => zoom >= z,
//                                     orElse: () => _clusterZoomLevels.first,
//                                   );
//                                   // ВСЕГДА отправляем ZoomChanged
//                                   context
//                                       .read<MapBloc>()
//                                       .add(ZoomChanged(zoom));
//                                   if (_lastClusterZoomLevel == null ||
//                                       _lastClusterZoomLevel != clusterZoom) {
//                                     _lastClusterZoomLevel = clusterZoom;
//                                   }
//                                   // Обрабатываем перемещение камеры
//                                   await _onCameraMove(camera);
//                                 }
//                               },
//                               onZoomListener: (ctx) {},
//                               onCameraChangeListener: (ctx) {},
//                               onScrollListener: (ctx) async {
//                                 // Обрабатываем перемещение камеры при скролле
//                                 if (mapboxMap != null) {
//                                   final camera =
//                                       await mapboxMap!.getCameraState();
//                                   await _onCameraMove(camera);
//                                 }
//                               },
//                               onStyleLoadedListener:
//                                   (styleLoadedEventData) async {
//                                 if (!mounted) return;
//                                 if (currentUserPosition != null &&
//                                     mapboxMap != null) {
//                                   await addUserIconToStyle(mapboxMap!);
//                                 }
//                                 // DEBUG PRINTS
//                                 print(
//                                     '[DEBUG] onStyleLoadedListener: searchedEventsModel: $searchedEventsModel');
//                                 if (searchedEventsModel != null) {
//                                   print(
//                                       '[DEBUG] searchedEventsModel.events.length: \u001b[34m${searchedEventsModel!.events.length}\u001b[0m');
//                                   context.read<MapBloc>().add(
//                                       LoadEvents(searchedEventsModel!.events));
//                                 }

//                                 // Обрабатываем события из очереди после загрузки стиля
//                                 if (_pendingMapState != null) {
//                                   print(
//                                       '[DEBUG] Обрабатываем события из очереди после загрузки стиля');
//                                   _handleMarkerChanges(_pendingMapState!);
//                                   _pendingMapState = null;
//                                 }
//                               },
//                               onTapListener: (gestureContext) {
//                                 print(
//                                     '[DEBUG] onTapListener: tap at lat=${gestureContext.point.coordinates.lat}, lng=${gestureContext.point.coordinates.lng}');
//                                 onMapTap(gestureContext, context, profileId);
//                               },
//                               cameraOptions: CameraOptions(
//                                 zoom: 15.0,
//                                 center: Point(
//                                   coordinates: Position(
//                                     currentSelectedPosition.lng,
//                                     currentSelectedPosition.lat,
//                                   ),
//                                 ),
//                               ),
//                               key: const ValueKey("MapWidget"),
//                               onMapCreated: _onMapCreated,
//                             ),
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: buildMapControls(),
//                             ),
//                             if (isMarkersLoading)
//                               // Аккуратный индикатор загрузки маркеров
//                               Center(
//                                 child: const Padding(
//                                   padding: EdgeInsets.all(12.0),
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 3,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             // Виджет статуса геолокации
//                             Positioned(
//                               top: 50,
//                               right: 80,
//                               left: 80,
//                               child: AnimatedOpacity(
//                                 opacity: _showLocationStatus ? 1.0 : 0.0,
//                                 duration: const Duration(milliseconds: 500),
//                                 child: GestureDetector(
//                                   onLongPress: () {
//                                     // Долгое нажатие для принудительного обновления позиции
//                                     refreshUserLocation();
//                                   },
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8, vertical: 4),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white.withOpacity(0.9),
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.1),
//                                           blurRadius: 4,
//                                           offset: const Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Icon(
//                                           currentUserPosition != null
//                                               ? Icons.location_on
//                                               : Icons.location_off,
//                                           size: 16,
//                                           color: currentUserPosition != null
//                                               ? Colors.green
//                                               : Colors.red,
//                                         ),
//                                         const SizedBox(width: 4),
//                                         Text(
//                                           currentUserPosition != null
//                                               ? 'Геолокация активна'
//                                               : 'Геолокация недоступна',
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             if (showEvents)
//                               DraggableScrollableSheet(
//                                 controller: sheetController,
//                                 initialChildSize: 0.8,
//                                 builder: (context, scrollController) {
//                                   return EventsHomeListOnMapWidget(
//                                       scrollController: scrollController);
//                                 },
//                               ),
//                           ],
//                         ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget buildMapControls() {
//     // Ensure controls are only built when selectedIndex is 0
//     // This check is also done in the Stack, but good to be explicit here too.
//     if (selectedIndex != 0) return SizedBox.shrink();

//     return Container(
//       width: 59,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(30),
//           bottomLeft: Radius.circular(30),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(top: 20, bottom: 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             IconButton(
//               icon: SvgPicture.asset('assets/left_drawer/filter.svg'),
//               onPressed: () {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   backgroundColor: Colors.transparent,
//                   builder: (context) => FilterMapSheet(
//                     currentPosition: currentUserPosition != null
//                         ? geolocator.Position(
//                             latitude: currentUserPosition!.lat.toDouble(),
//                             longitude: currentUserPosition!.lng.toDouble(),
//                             timestamp: DateTime.now(),
//                             accuracy: 0,
//                             altitude: 0,
//                             heading: 0,
//                             speed: 0,
//                             speedAccuracy: 0,
//                             altitudeAccuracy: 0,
//                             headingAccuracy: 0)
//                         : null,
//                     onApplyFilters: () {
//                       final filterProvider =
//                           Provider.of<FilterProvider>(context, listen: false);

//                       // Очищаем текущие маркеры и кэш
//                       if (pointAnnotationManager != null)
//                         pointAnnotationManager!.deleteAll();

//                       // Сбрасываем последнюю позицию запроса при применении фильтров
//                       _lastRequestPosition = null;

//                       // Определяем координаты для поиска
//                       double searchLat = currentSelectedPosition.lat.toDouble();
//                       double searchLng = currentSelectedPosition.lng.toDouble();

//                       // Если выбрана точка на карте в фильтре, используем её
//                       if (filterProvider.selectedMapAddressModel != null) {
//                         searchLat =
//                             filterProvider.selectedMapAddressModel!.latitude ??
//                                 searchLat;
//                         searchLng =
//                             filterProvider.selectedMapAddressModel!.longitude ??
//                                 searchLng;
//                       }

//                       // Определяем радиус поиска
//                       int radius = filterProvider.selectedRadius
//                           .round(); // используем значение в километрах
//                       // Ограничиваем радиус до 100 км
//                       if (radius > 100) {
//                         radius = 100;
//                       }

//                       // Формируем список ограничений
//                       List<String> restrictions = [];

//                       // Добавляем все ограничения из selectedAgeRestrictions
//                       restrictions
//                           .addAll(filterProvider.selectedAgeRestrictions);

//                       // Определяем длительность
//                       int? durationMin;
//                       int? durationMax;
//                       if (filterProvider.selectedDurationFilter == 'short') {
//                         durationMin = 1;
//                         durationMax = 2;
//                       } else if (filterProvider.selectedDurationFilter ==
//                           'medium') {
//                         durationMin = 3;
//                         durationMax = 5;
//                       } else if (filterProvider.selectedDurationFilter ==
//                           'long') {
//                         durationMin = 6;
//                         durationMax = 24;
//                       }

//                       // Логируем выбранные фильтры
//                       developer.log('Выбранные фильтры:', name: 'MAP_SEARCH');
//                       developer.log('Радиус: $radius км', name: 'MAP_SEARCH');
//                       developer.log('Ограничения: $restrictions',
//                           name: 'MAP_SEARCH');
//                       developer.log(
//                           'Длительность: $durationMin - $durationMax часов',
//                           name: 'MAP_SEARCH');
//                       developer.log(
//                           'Категории (${filterProvider.selectedCategoryIds.length}): ${filterProvider.selectedCategoryIds.join(", ")}',
//                           name: 'MAP_SEARCH');
//                       developer.log(
//                           'Цена: ${filterProvider.isFreeSelected == true ? "Бесплатно" : "${filterProvider.priceMinText} - ${filterProvider.priceMaxText}"}',
//                           name: 'MAP_SEARCH');
//                       developer.log(
//                           'Дата: ${filterProvider.selectedDateFrom} - ${filterProvider.selectedDateTo}',
//                           name: 'MAP_SEARCH');
//                       developer.log(
//                           'Время: ${filterProvider.selectedTimeFrom} - ${filterProvider.selectedTimeTo}',
//                           name: 'MAP_SEARCH');

//                       // Форматируем даты в формат YYYY-MM-DD
//                       String? formattedDateFrom;
//                       String? formattedDateTo;
//                       if (filterProvider.selectedDateFrom != null) {
//                         formattedDateFrom = DateFormat('yyyy-MM-dd')
//                             .format(filterProvider.selectedDateFrom!);
//                       }
//                       if (filterProvider.selectedDateTo != null) {
//                         formattedDateTo = DateFormat('yyyy-MM-dd')
//                             .format(filterProvider.selectedDateTo!);
//                       }

//                       // Отправляем событие ApplyFilter
//                       context.read<MapBloc>().add(ApplyFilter({
//                             'radius': radius,
//                             'restrictions': restrictions,
//                             'duration_min': durationMin,
//                             'duration_max': durationMax,
//                             'category_ids': filterProvider.selectedCategoryIds,
//                             'price_min': filterProvider.isFreeSelected == true
//                                 ? 0
//                                 : double.tryParse(filterProvider.priceMinText),
//                             'price_max': filterProvider.isFreeSelected == true
//                                 ? 0
//                                 : double.tryParse(filterProvider.priceMaxText),
//                             'date_from': formattedDateFrom,
//                             'date_to': formattedDateTo,
//                             'time_from': filterProvider.selectedTimeFrom,
//                             'time_to': filterProvider.selectedTimeTo,
//                             'slots_min': filterProvider.slotsMin,
//                             'slots_max': filterProvider.slotsMax,
//                             'is_organization': filterProvider.isOrganization,
//                           }));

//                       // Выполняем поиск с фильтрами
//                       context.read<ProfileBloc>().add(SearchEventsOnMapEvent(
//                             latitude: searchLat,
//                             longitude: searchLng,
//                             filters: {
//                               'radius': radius,
//                               'restrictions': restrictions,
//                               'duration_min': durationMin,
//                               'duration_max': durationMax,
//                               'category_ids':
//                                   filterProvider.selectedCategoryIds,
//                               'price_min': filterProvider.isFreeSelected == true
//                                   ? 0
//                                   : double.tryParse(
//                                       filterProvider.priceMinText),
//                               'price_max': filterProvider.isFreeSelected == true
//                                   ? 0
//                                   : double.tryParse(
//                                       filterProvider.priceMaxText),
//                               'date_from': formattedDateFrom,
//                               'date_to': formattedDateTo,
//                               'time_from': filterProvider.selectedTimeFrom,
//                               'time_to': filterProvider.selectedTimeTo,
//                               'slots_min': filterProvider.slotsMin,
//                               'slots_max': filterProvider.slotsMax,
//                               'is_organization': filterProvider.isOrganization,
//                             },
//                           ));
//                     },
//                   ),
//                 );
//               },
//             ),
//             IconButton(
//               onPressed: () async {
//                 if (mapboxMap != null) {
//                   final camera = await mapboxMap!.getCameraState();
//                   await mapboxMap!
//                       .setCamera(CameraOptions(zoom: camera.zoom - 1));
//                   final updatedCamera = await mapboxMap!.getCameraState();
//                   setState(() {
//                     currentZoom = updatedCamera.zoom;
//                   });
//                   // Добавлено: отправляем ZoomChanged
//                   context.read<MapBloc>().add(ZoomChanged(updatedCamera.zoom));
//                 }
//               },
//               icon: SvgPicture.asset('assets/left_drawer/minus.svg'),
//             ),
//             IconButton(
//               onPressed: () async {
//                 if (mapboxMap != null) {
//                   final camera = await mapboxMap!.getCameraState();
//                   await mapboxMap!
//                       .setCamera(CameraOptions(zoom: camera.zoom + 1));
//                   final updatedCamera = await mapboxMap!.getCameraState();
//                   setState(() {
//                     currentZoom = updatedCamera.zoom;
//                   });
//                   // Добавлено: отправляем ZoomChanged
//                   context.read<MapBloc>().add(ZoomChanged(updatedCamera.zoom));
//                 }
//               },
//               icon: SvgPicture.asset('assets/left_drawer/plus.svg'),
//             ),
//             IconButton(
//               onPressed: () async {
//                 if (currentUserPosition != null && mapboxMap != null) {
//                   await mapboxMap!.setCamera(CameraOptions(
//                       center: Point(
//                           coordinates: Position(currentUserPosition!.lng,
//                               currentUserPosition!.lat)),
//                       zoom: currentZoom));
//                   // Показываем статус только если геолокация активна
//                   _startLocationStatusTimer();
//                 } else {
//                   // Если позиция не определена, пытаемся получить её заново
//                   developer.log(
//                       'Позиция пользователя не определена, получаем заново',
//                       name: 'MAP_SCREEN');
//                   await _getUserLocation();

//                   // Если после обновления позиция определена, перемещаем камеру и показываем статус
//                   if (currentUserPosition != null && mapboxMap != null) {
//                     await mapboxMap!.setCamera(CameraOptions(
//                         center: Point(
//                             coordinates: Position(currentUserPosition!.lng,
//                                 currentUserPosition!.lat)),
//                         zoom: currentZoom));
//                     _startLocationStatusTimer();
//                   } else {
//                     // Если всё ещё не удалось получить позицию, показываем сообщение и явно показываем статус "недоступна"
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text(
//                               'Не удалось определить вашу позицию. Проверьте настройки геолокации.'),
//                           duration: Duration(seconds: 3),
//                         ),
//                       );
//                       setState(() {
//                         _showLocationStatus = true;
//                       });
//                     }
//                   }
//                 }
//               },
//               icon: SvgPicture.asset('assets/left_drawer/my_location.svg'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _onMapCreated(MapboxMap mapboxMap) async {
//     if (!mounted) return;
//     setState(() {
//       this.mapboxMap = mapboxMap;
//       _mapboxMap = mapboxMap;
//     });
//     context.read<MapBloc>().setMapbox(mapboxMap);
//     print('[DEBUG] MapScreen: mapboxMap передан в MapBloc');

//     // Сохраняем profileId глобально для обработчика
//     _lastProfileId = profileId;

//     // Сбрасываем флаг регистрации обработчика клика
//     _isClickListenerRegistered = false;

//     // Применяем оптимизированные настройки жестов
//     try {
//       await mapboxMap.gestures.updateSettings(
//           _mapOptimizationService.getOptimizedGesturesSettings());
//     } catch (e) {
//       developer.log('Ошибка применения оптимизированных настроек жестов: $e',
//           name: 'MAP_SCREEN');
//     }

//     await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
//     await mapboxMap.logo.updateSettings(LogoSettings(enabled: true));
//     await mapboxMap.attribution
//         .updateSettings(AttributionSettings(enabled: true));
//     await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));

//     // Загружаем стиль в фоне, не блокируя UI
//     Future.microtask(() async {
//       await _loadLocalStyle();
//     });

//     final pointNewAnnotationManager =
//         await mapboxMap.annotations.createPointAnnotationManager();
//     setState(() {
//       pointAnnotationManager = pointNewAnnotationManager;
//     });
//     // Удаляем все маркеры при создании карты
//     await pointAnnotationManager?.deleteAll();

//     // Регистрируем обработчик нажатия на маркеры
//     // Регистрируем только один раз
//     if (!_isClickListenerRegistered) {
//       pointAnnotationManager?.addOnPointAnnotationClickListener(
//           _MyPointAnnotationClickListener());
//       _isClickListenerRegistered = true;
//       print('[DEBUG] Обработчик клика по маркерам зарегистрирован');
//     } else {
//       print('[DEBUG] Обработчик клика уже зарегистрирован, пропускаем');
//     }

//     // Обрабатываем события из очереди, если они есть
//     if (_pendingMapState != null) {
//       print(
//           '[DEBUG] Обрабатываем события из очереди после инициализации карты');
//       _handleMarkerChanges(_pendingMapState!);
//       _pendingMapState = null;
//     }
//   }

//   /// Обработка изменений маркеров (добавление новых и удаление старых)
//   Future<void> _handleMarkerChanges(MapState mapState) async {
//     print('[DEBUG] ===== НАЧАЛО _handleMarkerChanges =====');

//     // Проверяем, есть ли новые события или события для удаления
//     final hasNewEvents = mapState.newEventIds.isNotEmpty;
//     final hasRemovedEvents = mapState.removedEventIds.isNotEmpty;

//     if (!hasNewEvents && !hasRemovedEvents) {
//       print('[DEBUG] Нет изменений в маркерах, пропускаем обработку');
//       return;
//     }

//     // Удаляем маркеры для событий, которых больше нет
//     if (hasRemovedEvents) {
//       print('[DEBUG] Удаляем ${mapState.removedEventIds.length} маркеров');
//       for (final eventId in mapState.removedEventIds) {
//         _addedMarkerIds.remove(eventId);
//         print('[DEBUG] Удален из кэша маркер: $eventId');
//       }
//     }

//     // Добавляем новые маркеры
//     if (hasNewEvents) {
//       print('[DEBUG] Добавляем ${mapState.newEventIds.length} новых маркеров');

//       // Если все события новые (инициализация, смена области или изменение типа маркеров), отображаем все
//       if (mapState.newEventIds.length == mapState.groupedEvents.length) {
//         print(
//             '[DEBUG] Инициализация/смена области/изменение типа маркеров - отображаем все события');
//         // Очищаем кэш маркеров для пересоздания
//         print('[DEBUG] Удаляем все старые маркеры перед перерисовкой...');
//         await pointAnnotationManager?.deleteAll();
//         _addedMarkerIds.clear();
//         _markerCache.clear();
//         await _drawAllMarkers(mapState.groupedEvents);
//       } else {
//         // Обычное обновление - добавляем только новые
//         final newGroups = mapState.groupedEvents.where((group) {
//           final eventId = group.first.id.toString();
//           return mapState.newEventIds.contains(eventId);
//         }).toList();

//         await _drawNewMarkers(newGroups);
//       }
//     }

//     print('[DEBUG] ===== КОНЕЦ _handleMarkerChanges =====');
//   }

//   /// Отрисовка только новых маркеров
//   Future<void> _drawNewMarkers(
//       List<List<OrganizedEventModel>> newGroups) async {
//     print('[DEBUG] ===== НАЧАЛО _drawNewMarkers =====');
//     print('[DEBUG] Новых групп для отрисовки: ${newGroups.length}');

//     if (mapboxMap == null || pointAnnotationManager == null) {
//       print('[DEBUG] mapboxMap или pointAnnotationManager null, выход');
//       return;
//     }

//     // Устанавливаем флаг загрузки только если есть события для обработки
//     if (newGroups.isNotEmpty) {
//       setState(() {
//         isMarkersLoading = true;
//       });
//     }

//     final mapState = BlocProvider.of<MapBloc>(context, listen: false).state;
//     final double zoom = mapState.zoom;
//     final List<PointAnnotationOptions> optionsList = [];
//     final List<String> iconIds = [];
//     final List<String> newMarkerIds = [];

//     for (int i = 0; i < newGroups.length; i++) {
//       final group = newGroups[i];
//       final event = group.first;
//       final lat = event.latitude;
//       final lng = event.longitude;

//       if (lat == null || lng == null) {
//         print('[DEBUG] Пропускаем событие ${event.id}: координаты null');
//         continue;
//       }

//       final eventId = event.id.toString();
//       print(
//           '[DEBUG] Создаем новый маркер для события: id=${event.id}, lat=$lat, lng=$lng');

//       try {
//         final cacheKey = '${event.id}_${zoom.toStringAsFixed(1)}';
//         Uint8List result;

//         // Пытаемся использовать предварительно загруженные изображения
//         final markerType = mapState.markerType;
//         String? prebuiltKey;

//         if (markerType == 'simple') {
//           prebuiltKey = 'simple';
//         } else if (group.length > 1) {
//           if (zoom < 12) {
//             prebuiltKey = 'circle_${group.length}';
//           } else {
//             prebuiltKey = 'grouped_${group.length}';
//           }
//         }

//         // Проверяем кэш готовых маркеров категорий для одиночных событий
//         if (group.length == 1) {
//           // Проверяем наличие категории
//           if (event.category != null) {
//             final categoryCacheKey = 'category_marker_${event.category!.id}';
//             if (_categoryMarkerCache.containsKey(categoryCacheKey)) {
//               result = _categoryMarkerCache[categoryCacheKey]!;
//               print(
//                   '[DEBUG] Используем кэшированный маркер категории: ${event.category!.id}');
//             } else if (prebuiltKey != null &&
//                 _prebuiltMarkerImages.containsKey(prebuiltKey)) {
//               result = _prebuiltMarkerImages[prebuiltKey]!;
//               print(
//                   '[DEBUG] Используем предварительно загруженное изображение для $prebuiltKey');
//             } else if (_markerCache.containsKey(cacheKey)) {
//               result = _markerCache[cacheKey]!;
//               print('[DEBUG] Используем кэшированный маркер для $cacheKey');
//             } else {
//               print('[DEBUG] Создаем новый маркер для $cacheKey');
//               result = await screenshotController.captureFromWidget(
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     _buildMarker(group, zoom),
//                   ],
//                 ),
//               );
//               _markerCache[cacheKey] = result;
//             }
//           } else {
//             // Если категории нет, используем SimpleBluePoint
//             if (prebuiltKey != null &&
//                 _prebuiltMarkerImages.containsKey(prebuiltKey)) {
//               result = _prebuiltMarkerImages[prebuiltKey]!;
//               print(
//                   '[DEBUG] Используем предварительно загруженное изображение для $prebuiltKey');
//             } else if (_markerCache.containsKey(cacheKey)) {
//               result = _markerCache[cacheKey]!;
//               print('[DEBUG] Используем кэшированный маркер для $cacheKey');
//             } else {
//               print('[DEBUG] Создаем новый маркер для $cacheKey');
//               result = await screenshotController.captureFromWidget(
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     _buildMarker(group, zoom),
//                   ],
//                 ),
//               );
//               _markerCache[cacheKey] = result;
//             }
//           }
//         } else {
//           // Для групп используем стандартную логику
//           if (prebuiltKey != null &&
//               _prebuiltMarkerImages.containsKey(prebuiltKey)) {
//             result = _prebuiltMarkerImages[prebuiltKey]!;
//             print(
//                 '[DEBUG] Используем предварительно загруженное изображение для $prebuiltKey');
//           } else if (_markerCache.containsKey(cacheKey)) {
//             result = _markerCache[cacheKey]!;
//             print('[DEBUG] Используем кэшированный маркер для $cacheKey');
//           } else {
//             print('[DEBUG] Создаем новый маркер для $cacheKey');
//             result = await screenshotController.captureFromWidget(
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   _buildMarker(group, zoom),
//                 ],
//               ),
//             );
//             _markerCache[cacheKey] = result;
//           }
//         }

//         final iconId = 'pointer:${event.id}';
//         await addEventIconFromUrl(mapboxMap!, iconId, result);
//         iconIds.add(iconId);

//         final pointAnnotationOptions = PointAnnotationOptions(
//           geometry: Point(coordinates: Position(lng, lat)),
//           iconSize: 1.0, // Увеличиваем размер для лучшей видимости новых иконок
//           image: result,
//           iconImage: iconId,
//         );
//         optionsList.add(pointAnnotationOptions);
//         newMarkerIds.add(eventId);
//         print('[DEBUG] Маркер подготовлен для события ${event.id}');
//       } catch (e, st) {
//         print(
//             '[ERROR] Ошибка при создании маркера для события ${event.id}: $e\n$st');
//       }
//     }

//     print(
//         '[DEBUG] Подготовлено ${optionsList.length} новых маркеров для добавления');

//     // Добавляем только новые маркеры
//     final List<PointAnnotation> newAnnotations = [];
//     for (final options in optionsList) {
//       try {
//         final annotation = await pointAnnotationManager!.create(options);
//         newAnnotations.add(annotation);
//         print('[DEBUG] Новый маркер добавлен на карту');
//       } catch (e) {
//         print('[ERROR] Не удалось создать аннотацию: $e');
//       }
//     }

//     // Добавляем ID новых маркеров в кэш
//     _addedMarkerIds.addAll(newMarkerIds);

//     // Убираем флаг загрузки только если он был установлен
//     if (newGroups.isNotEmpty) {
//       setState(() {
//         isMarkersLoading = false;
//       });
//     }

//     print(
//         '[DEBUG] Новых маркеров добавлено: \u001b[32m${newAnnotations.length}\u001b[0m');
//     print(
//         '[DEBUG] Всего маркеров на карте: \u001b[33m${_addedMarkerIds.length}\u001b[0m');
//     print('[DEBUG] ===== КОНЕЦ _drawNewMarkers =====');
//   }

//   /// Отрисовка всех маркеров при инициализации
//   Future<void> _drawAllMarkers(
//       List<List<OrganizedEventModel>> allGroups) async {
//     print('[DEBUG] ===== НАЧАЛО _drawAllMarkers =====');
//     print('[DEBUG] Всех групп для отрисовки: ${allGroups.length}');

//     if (mapboxMap == null || pointAnnotationManager == null) {
//       print('[DEBUG] mapboxMap или pointAnnotationManager null, выход');
//       return;
//     }

//     // Устанавливаем флаг загрузки только если есть события для обработки
//     if (allGroups.isNotEmpty) {
//       setState(() {
//         isMarkersLoading = true;
//       });
//     }

//     final mapState = BlocProvider.of<MapBloc>(context, listen: false).state;
//     final double zoom = mapState.zoom;
//     final List<PointAnnotationOptions> optionsList = [];
//     final List<String> iconIds = [];
//     final List<String> newMarkerIds = [];

//     for (int i = 0; i < allGroups.length; i++) {
//       final group = allGroups[i];
//       final event = group.first;
//       final lat = event.latitude;
//       final lng = event.longitude;

//       if (lat == null || lng == null) {
//         print('[DEBUG] Пропускаем событие ${event.id}: координаты null');
//         continue;
//       }

//       final eventId = event.id.toString();

//       // При инициализации или смене области создаем маркеры для всех событий
//       print(
//           '[DEBUG] Создаем маркер для события: id=${event.id}, lat=$lat, lng=$lng');

//       try {
//         final cacheKey = '${event.id}_${zoom.toStringAsFixed(1)}';
//         Uint8List result;

//         // Пытаемся использовать предварительно загруженные изображения
//         final markerType = mapState.markerType;
//         String? prebuiltKey;

//         if (markerType == 'simple') {
//           prebuiltKey = 'simple';
//         } else if (group.length > 1) {
//           if (zoom < 12) {
//             prebuiltKey = 'circle_${group.length}';
//           } else {
//             prebuiltKey = 'grouped_${group.length}';
//           }
//         }

//         // Проверяем кэш готовых маркеров категорий для одиночных событий
//         if (group.length == 1) {
//           // Проверяем наличие категории
//           if (event.category != null) {
//             final categoryCacheKey = 'category_marker_${event.category!.id}';
//             if (_categoryMarkerCache.containsKey(categoryCacheKey)) {
//               result = _categoryMarkerCache[categoryCacheKey]!;
//               print(
//                   '[DEBUG] Используем кэшированный маркер категории: ${event.category!.id}');
//             } else if (prebuiltKey != null &&
//                 _prebuiltMarkerImages.containsKey(prebuiltKey)) {
//               result = _prebuiltMarkerImages[prebuiltKey]!;
//               print(
//                   '[DEBUG] Используем предварительно загруженное изображение для $prebuiltKey');
//             } else if (_markerCache.containsKey(cacheKey)) {
//               result = _markerCache[cacheKey]!;
//               print('[DEBUG] Используем кэшированный маркер для $cacheKey');
//             } else {
//               print('[DEBUG] Создаем новый маркер для $cacheKey');
//               result = await screenshotController.captureFromWidget(
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     _buildMarker(group, zoom),
//                   ],
//                 ),
//               );
//               _markerCache[cacheKey] = result;
//             }
//           } else {
//             // Если категории нет, используем SimpleBluePoint
//             if (prebuiltKey != null &&
//                 _prebuiltMarkerImages.containsKey(prebuiltKey)) {
//               result = _prebuiltMarkerImages[prebuiltKey]!;
//               print(
//                   '[DEBUG] Используем предварительно загруженное изображение для $prebuiltKey');
//             } else if (_markerCache.containsKey(cacheKey)) {
//               result = _markerCache[cacheKey]!;
//               print('[DEBUG] Используем кэшированный маркер для $cacheKey');
//             } else {
//               print('[DEBUG] Создаем новый маркер для $cacheKey');
//               result = await screenshotController.captureFromWidget(
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     _buildMarker(group, zoom),
//                   ],
//                 ),
//               );
//               _markerCache[cacheKey] = result;
//             }
//           }
//         } else {
//           // Для групп используем стандартную логику
//           if (prebuiltKey != null &&
//               _prebuiltMarkerImages.containsKey(prebuiltKey)) {
//             result = _prebuiltMarkerImages[prebuiltKey]!;
//             print(
//                 '[DEBUG] Используем предварительно загруженное изображение для $prebuiltKey');
//           } else if (_markerCache.containsKey(cacheKey)) {
//             result = _markerCache[cacheKey]!;
//             print('[DEBUG] Используем кэшированный маркер для $cacheKey');
//           } else {
//             print('[DEBUG] Создаем новый маркер для $cacheKey');
//             result = await screenshotController.captureFromWidget(
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   _buildMarker(group, zoom),
//                 ],
//               ),
//             );
//             _markerCache[cacheKey] = result;
//           }
//         }

//         final iconId = 'pointer:${event.id}';
//         await addEventIconFromUrl(mapboxMap!, iconId, result);
//         iconIds.add(iconId);

//         final pointAnnotationOptions = PointAnnotationOptions(
//           geometry: Point(coordinates: Position(lng, lat)),
//           iconSize: 1.0, // Увеличиваем размер для лучшей видимости новых иконок
//           image: result,
//           iconImage: iconId,
//         );
//         optionsList.add(pointAnnotationOptions);
//         newMarkerIds.add(eventId);
//         print('[DEBUG] Маркер подготовлен для события ${event.id}');
//       } catch (e, st) {
//         print(
//             '[ERROR] Ошибка при создании маркера для события ${event.id}: $e\n$st');
//       }
//     }

//     print('[DEBUG] Подготовлено ${optionsList.length} маркеров для добавления');

//     // Добавляем все маркеры
//     final List<PointAnnotation> newAnnotations = [];
//     for (final options in optionsList) {
//       try {
//         final annotation = await pointAnnotationManager!.create(options);
//         newAnnotations.add(annotation);
//         print('[DEBUG] Маркер добавлен на карту');
//       } catch (e) {
//         print('[ERROR] Не удалось создать аннотацию: $e');
//       }
//     }

//     // Добавляем ID всех маркеров в кэш
//     _addedMarkerIds.addAll(newMarkerIds);

//     // Убираем флаг загрузки только если он был установлен
//     if (allGroups.isNotEmpty) {
//       setState(() {
//         isMarkersLoading = false;
//       });
//     }

//     print(
//         '[DEBUG] Маркеров добавлено: \u001b[32m${newAnnotations.length}\u001b[0m');
//     print(
//         '[DEBUG] Всего маркеров на карте: \u001b[33m${_addedMarkerIds.length}\u001b[0m');
//     print('[DEBUG] ===== КОНЕЦ _drawAllMarkers =====');
//   }

//   // Вспомогательная функция для выбора типа маркера события/группы
//   Widget _buildMarker(List<OrganizedEventModel> group, double zoom) {
//     // Получаем тип маркеров из Bloc
//     final mapState = BlocProvider.of<MapBloc>(context, listen: false).state;
//     final markerType = mapState.markerType;
//     print(
//         '[DEBUG] _buildMarker: markerType=$markerType, zoom=$zoom, group.length=${group.length}');

//     // Используем тип маркеров из Bloc вместо локального расчета
//     if (markerType == 'simple') {
//       print(
//           '[DEBUG] _buildMarker: возвращаю SimpleBluePoint (markerType == simple)');
//       return const SimpleBluePoint();
//     }

//     if (group.length > 1) {
//       // Для групп: при сильном отдалении — круг, иначе GroupedMarker
//       if (zoom < 12) {
//         print('[DEBUG] _buildMarker: возвращаю CircleCountMarker (group)');
//         return CircleCountMarker(count: group.length);
//       } else {
//         print('[DEBUG] _buildMarker: возвращаю GroupedMarker (group)');
//         return GroupedMarker(count: group.length);
//       }
//     } else {
//       // Для одиночных событий: используем CategoryMarker с иконкой из бэкенда, если категория есть
//       final event = group.first;

//       // Проверяем наличие категории
//       if (event.category == null) {
//         print(
//             '[DEBUG] _buildMarker: событие ${event.id} не имеет категории, возвращаю SimpleBluePoint');
//         return const SimpleBluePoint();
//       }

//       final categoryId = event.category!.id;
//       final preloadedImage = _categoryImageCache[categoryId];

//       print(
//           '[DEBUG] _buildMarker: возвращаю OptimizedCategoryMarker для categoryId=$categoryId');
//       // Используем OptimizedCategoryMarker с предзагруженным изображением
//       return OptimizedCategoryMarker(
//         title: event.category!.name,
//         preloadedImage: preloadedImage,
//       );
//     }
//   }

//   /// Предварительная загрузка изображений маркеров для быстрого переключения
//   Future<void> _preloadMarkerImages() async {
//     print('[DEBUG] Начинаем предварительную загрузку изображений маркеров');

//     try {
//       // Загружаем SimpleBluePoint
//       if (!_prebuiltMarkerImages.containsKey('simple')) {
//         final simpleImage = await screenshotController.captureFromWidget(
//           const SimpleBluePoint(),
//         );
//         _prebuiltMarkerImages['simple'] = simpleImage;
//         print('[DEBUG] Загружено изображение для SimpleBluePoint');
//       }

//       // Загружаем CircleCountMarker с разными количествами
//       for (int count = 2; count <= 10; count++) {
//         final key = 'circle_$count';
//         if (!_prebuiltMarkerImages.containsKey(key)) {
//           final circleImage = await screenshotController.captureFromWidget(
//             CircleCountMarker(count: count),
//           );
//           _prebuiltMarkerImages[key] = circleImage;
//           print('[DEBUG] Загружено изображение для CircleCountMarker($count)');
//         }
//       }

//       // Загружаем GroupedMarker с разными количествами
//       for (int count = 2; count <= 10; count++) {
//         final key = 'grouped_$count';
//         if (!_prebuiltMarkerImages.containsKey(key)) {
//           final groupedImage = await screenshotController.captureFromWidget(
//             GroupedMarker(count: count),
//           );
//           _prebuiltMarkerImages[key] = groupedImage;
//           print('[DEBUG] Загружено изображение для GroupedMarker($count)');
//         }
//       }

//       print('[DEBUG] Предварительная загрузка изображений маркеров завершена');
//     } catch (e) {
//       print(
//           '[ERROR] Ошибка при предварительной загрузке изображений маркеров: $e');
//     }
//   }

//   /// Быстрое переключение типа маркеров без пересоздания
//   Future<void> _fastSwitchMarkerType(String newMarkerType) async {
//     print('[DEBUG] Быстрое переключение типа маркеров на: $newMarkerType');

//     if (mapboxMap == null || pointAnnotationManager == null) {
//       print('[DEBUG] Карта не готова для быстрого переключения');
//       return;
//     }

//     // Удаляем все текущие маркеры
//     await pointAnnotationManager!.deleteAll();
//     _addedMarkerIds.clear();

//     // Получаем текущие события
//     final mapState = BlocProvider.of<MapBloc>(context, listen: false).state;
//     if (mapState.groupedEvents.isEmpty) {
//       print('[DEBUG] Нет событий для переключения');
//       return;
//     }

//     // Быстро создаем новые маркеры с предварительно загруженными изображениями
//     final List<PointAnnotationOptions> optionsList = [];
//     final List<String> newMarkerIds = [];

//     for (final group in mapState.groupedEvents) {
//       final event = group.first;
//       final lat = event.latitude;
//       final lng = event.longitude;

//       if (lat == null || lng == null) continue;

//       final eventId = event.id.toString();
//       String? prebuiltKey;

//       if (newMarkerType == 'simple') {
//         prebuiltKey = 'simple';
//       } else if (group.length > 1) {
//         if (mapState.zoom < 12) {
//           prebuiltKey = 'circle_${group.length}';
//         } else {
//           prebuiltKey = 'grouped_${group.length}';
//         }
//       }

//       if (prebuiltKey != null &&
//           _prebuiltMarkerImages.containsKey(prebuiltKey)) {
//         final result = _prebuiltMarkerImages[prebuiltKey]!;
//         final iconId = 'pointer:${event.id}';

//         try {
//           await addEventIconFromUrl(mapboxMap!, iconId, result);

//           final pointAnnotationOptions = PointAnnotationOptions(
//             geometry: Point(coordinates: Position(lng, lat)),
//             iconSize:
//                 1.0, // Увеличиваем размер для лучшей видимости новых иконок
//             image: result,
//             iconImage: iconId,
//           );
//           optionsList.add(pointAnnotationOptions);
//           newMarkerIds.add(eventId);
//         } catch (e) {
//           print('[ERROR] Ошибка при быстром переключении маркера: $e');
//         }
//       }
//     }

//     // Добавляем все маркеры сразу
//     for (final options in optionsList) {
//       try {
//         await pointAnnotationManager!.create(options);
//       } catch (e) {
//         print(
//             '[ERROR] Не удалось создать аннотацию при быстром переключении: $e');
//       }
//     }

//     _addedMarkerIds.addAll(newMarkerIds);
//     print(
//         '[DEBUG] Быстрое переключение завершено: ${newMarkerIds.length} маркеров');
//   }

//   /// Предварительная загрузка изображений категорий
//   Future<void> _preloadCategoryImages(List<OrganizedEventModel> events) async {
//     print('[DEBUG] Начинаем предварительную загрузку изображений категорий');

//     final uniqueCategories = <String, String>{};
//     for (final event in events) {
//       // Проверяем наличие категории
//       if (event.category != null) {
//         uniqueCategories[event.category!.id] = event.category!.iconPath;
//       }
//     }

//     print(
//         '[DEBUG] Найдено ${uniqueCategories.length} уникальных категорий для загрузки');

//     for (final entry in uniqueCategories.entries) {
//       final categoryId = entry.key;
//       final iconUrl = entry.value;

//       if (!_categoryImageCache.containsKey(categoryId)) {
//         try {
//           print(
//               '[DEBUG] Загружаем изображение категории: $categoryId ($iconUrl)');

//           // Используем CachedNetworkImage для загрузки и кэширования
//           final imageProvider = CachedNetworkImageProvider(iconUrl);
//           final imageStream = imageProvider.resolve(const ImageConfiguration());

//           final completer = Completer<Uint8List>();
//           imageStream.addListener(ImageStreamListener((info, _) async {
//             try {
//               final byteData =
//                   await info.image.toByteData(format: ImageByteFormat.png);
//               if (byteData != null) {
//                 completer.complete(byteData.buffer.asUint8List());
//               } else {
//                 completer
//                     .completeError('Не удалось получить данные изображения');
//               }
//             } catch (e) {
//               completer.completeError(e);
//             }
//           }, onError: (error, stackTrace) {
//             completer.completeError(error, stackTrace);
//           }));

//           final imageBytes = await completer.future;
//           _categoryImageCache[categoryId] = imageBytes;
//           print('[DEBUG] Успешно загружено изображение категории: $categoryId');
//         } catch (e) {
//           print(
//               '[ERROR] Ошибка загрузки изображения категории $categoryId ($iconUrl): $e');
//         }
//       } else {
//         print('[DEBUG] Изображение категории $categoryId уже в кэше');
//       }
//     }

//     print(
//         '[DEBUG] Предварительная загрузка изображений категорий завершена. Загружено: ${_categoryImageCache.length}');
//   }

//   /// Создание кэша готовых маркеров категорий
//   Future<void> _createCategoryMarkerCache(
//       List<OrganizedEventModel> events) async {
//     print('[DEBUG] Начинаем создание кэша готовых маркеров категорий');

//     final uniqueCategories = <String, String>{};
//     for (final event in events) {
//       // Проверяем наличие категории
//       if (event.category != null) {
//         uniqueCategories[event.category!.id] = event.category!.name;
//       }
//     }

//     print(
//         '[DEBUG] Найдено ${uniqueCategories.length} уникальных категорий для создания маркеров');

//     for (final entry in uniqueCategories.entries) {
//       final categoryId = entry.key;
//       final categoryName = entry.value;
//       final cacheKey = 'category_marker_$categoryId';

//       if (!_categoryMarkerCache.containsKey(cacheKey)) {
//         try {
//           print(
//               '[DEBUG] Создаем маркер для категории: $categoryId ($categoryName)');

//           final preloadedImage = _categoryImageCache[categoryId];
//           final markerImage = await screenshotController.captureFromWidget(
//             OptimizedCategoryMarker(
//               title: categoryName,
//               preloadedImage: preloadedImage,
//             ),
//           );
//           _categoryMarkerCache[cacheKey] = markerImage;
//           print(
//               '[DEBUG] Успешно создан кэш маркера для категории: $categoryId');
//         } catch (e) {
//           print(
//               '[ERROR] Ошибка создания кэша маркера для категории $categoryId: $e');
//         }
//       } else {
//         print('[DEBUG] Маркер категории $categoryId уже в кэше');
//       }
//     }

//     print(
//         '[DEBUG] Создание кэша готовых маркеров категорий завершено. Создано: ${_categoryMarkerCache.length}');
//   }
// }

// class CircleCountMarker extends StatelessWidget {
//   final int count;
//   const CircleCountMarker({super.key, required this.count});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.white, width: 2),
//         color: Colors.green,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         '$count',
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 18,
//         ),
//       ),
//     );
//   }
// }

// class SimpleBluePoint extends StatelessWidget {
//   const SimpleBluePoint({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 22,
//       height: 22,
//       decoration: BoxDecoration(
//         color: Colors.blue,
//         border: Border.all(color: Colors.white, width: 2),
//         shape: BoxShape.circle,
//         // boxShadow: [
//         //   BoxShadow(
//         //     color: Colors.black.withOpacity(0.2),
//         //     blurRadius: 2,
//         //     offset: const Offset(0, 1),
//         //   ),
//         // ],
//       ),
//     );
//   }
// }
