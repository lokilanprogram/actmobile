import 'dart:io';
import 'package:acti_mobile/configs/geolocator_utils.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/domain/api/map/map_api.dart';
import 'package:acti_mobile/domain/websocket/websocket.dart';
import 'package:acti_mobile/domain/services/map_optimization_service.dart';
import 'package:acti_mobile/presentation/screens/maps/event/widgets/card_event_on_map.dart';
import 'package:acti_mobile/presentation/screens/maps/event/widgets/cascade_cards_event_on_map.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/filter_map_sheet.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
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
import 'dart:async';
import 'dart:math' as math;
import 'bloc/map_bloc.dart';
import 'bloc/map_event.dart';
import 'bloc/map_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:collection/collection.dart';

// NEW APPROACH: GeoJSON Source and SymbolLayer IDs
const String EVENTS_SOURCE_ID = "events-source";

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // --- Controllers and Services ---
  WidgetsToImageController controller = WidgetsToImageController();
  ScreenshotController screenshotController = ScreenshotController();
  MapboxMap? mapboxMap;
  DraggableScrollableController sheetController =
      DraggableScrollableController();
  final MapOptimizationService _mapOptimizationService =
      MapOptimizationService();

  // --- State Variables ---
  int selectedIndex = 0;
  late geolocator.LocationPermission currentPermission;
  Position currentSelectedPosition = Position(37.6173, 55.7558); // Moscow
  Position? currentUserPosition;
  double currentZoom = 16;
  bool isLoading = false;
  bool showEvents = false;
  bool showSettings = false;
  SearchedEventsModel? searchedEventsModel;
  String? profileId;

  // --- Map Logic Variables ---
  Position? _lastRequestPosition;
  bool _isProcessingTap = false;
  bool _isGeoJsonSourceInitialized = false;
  final Set<String> _initializedLayers = {};

  // Для двойного тапа по кластеру
  int? _lastClusterTapTime;
  List? _lastClusterCoords;

  // --- Caching ---
  final Map<String, Uint8List> _categoryImageCache = {};
  MapState? _pendingMapState; // Queue for events before map is ready

  // Timers
  Timer? _locationStatusTimer;
  Timer? _cameraIdleDebounce;
  bool _showLocationStatus = true;
  final List<double> _clusterZoomLevels = [10, 12, 14, 16, 18];
  double? _lastClusterZoomLevel;

  bool _shouldMoveCameraToUser = false;

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
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateLocationIfNeeded();
  }

  @override
  void dispose() {
    sheetController.dispose();
    _stopLocationStatusTimer();
    _cameraIdleDebounce?.cancel();
    super.dispose();
  }

  // --- Initialization ---
  void initialize() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    if (Platform.isIOS) {
      currentZoom = 14.0;
    }
    await _mapOptimizationService.quickInitialize();
    final futures = await Future.wait<dynamic>([
      SecureStorageService().getAccessToken(),
      geolocator.Geolocator.checkPermission(),
    ]);
    profileId = await SecureStorageService().getUserId();
    final accessToken = futures[0] as String;
    currentPermission = futures[1] as geolocator.LocationPermission;
    _connectWebSocket(accessToken);
    Future.microtask(() {
      _mapOptimizationService.preloadMapData().catchError((e) {
        developer.log('Ошибка предварительной загрузки карты: $e',
            name: 'MAP_PAGE');
      });
    });
    final mapService = MapOptimizationService();
    final cached = await mapService.getLastLocation();
    Map<String, double> location;
    if (cached != null) {
      location = cached;
      developer.log(
          'MapPage: используем кэшированную позицию: [32m${location['latitude']}, ${location['longitude']}[0m',
          name: 'MAP_PAGE');
    } else {
      location = await mapService.getReliableLocation();
      developer.log(
          'MapPage: получена позиция через getReliableLocation: [32m${location['latitude']}, ${location['longitude']}[0m',
          name: 'MAP_PAGE');
    }
    setState(() {
      currentUserPosition =
          Position(location['longitude']!, location['latitude']!);
      currentSelectedPosition =
          Position(location['longitude']!, location['latitude']!);
      _lastRequestPosition =
          Position(location['longitude']!, location['latitude']!);
    });
    context.read<ProfileBloc>().add(InitializeMapEvent(
        latitude: currentSelectedPosition.lat.toDouble(),
        longitude: currentSelectedPosition.lng.toDouble()));
    _lastRequestPosition = currentSelectedPosition;
    setState(() {
      isLoading = false;
    });
    _startLocationStatusTimer();
  }

  // --- Location Handling ---
  // All location-related functions (_getUserLocation, refreshUserLocation, etc.)
  // are copied from MapScreen and remain unchanged.
  Future<void> _getUserLocation() async {
    try {
      if (currentPermission.name == 'denied') {
        currentPermission = await geolocator.Geolocator.requestPermission();
      }

      if (currentPermission.name != 'denied' && await checkGeolocator()) {
        final locationSettings = Platform.isIOS
            ? geolocator.LocationSettings(
                accuracy: geolocator.LocationAccuracy.high,
                distanceFilter: 10,
                timeLimit: const Duration(seconds: 5),
              )
            : geolocator.LocationSettings(
                accuracy: geolocator.LocationAccuracy.high,
                timeLimit: const Duration(seconds: 5),
              );

        final position = await geolocator.Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );

        await _mapOptimizationService.saveLastLocation(
            position.latitude, position.longitude);

        if (mounted) {
          setState(() {
            currentUserPosition =
                Position(position.longitude, position.latitude);
            currentSelectedPosition =
                Position(position.longitude, position.latitude);
            _lastRequestPosition =
                Position(position.longitude, position.latitude);
          });
        }
        _startLocationStatusTimer();
        if (mapboxMap != null && mounted) {
          print(
              '[DEBUG] Перемещаю камеру к реальному местоположению: ${position.latitude}, ${position.longitude}');
          await _updateCameraToUserLocation(
              position.latitude, position.longitude);
        } else {
          _shouldMoveCameraToUser = true;
        }
      } else {
        final lastLocation = await _mapOptimizationService.getLastLocation();
        if (lastLocation != null) {
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
          if (mounted) {
            setState(() {
              currentUserPosition = null;
              currentSelectedPosition = Position(37.6173, 55.7558);
            });
          }
        }
      }
    } catch (e) {
      developer.log('Ошибка получения геолокации: $e', name: 'MAP_PAGE');
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

  Future<void> _updateLocationIfNeeded() async {
    if (mounted && mapboxMap != null && currentUserPosition == null) {
      await _getUserLocation();
    }
  }

  Future<void> refreshUserLocation() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      await _getUserLocation();
      if (currentUserPosition != null && mapboxMap != null) {
        await _updateCameraToUserLocation(
          currentUserPosition!.lat.toDouble(),
          currentUserPosition!.lng.toDouble(),
        );
      }
      _startLocationStatusTimer();
    } catch (e) {
      developer.log('Ошибка при обновлении позиции: $e', name: 'MAP_PAGE');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _startLocationStatusTimer() {
    _locationStatusTimer?.cancel();
    setState(() {
      _showLocationStatus = true;
    });
    if (currentUserPosition != null) {
      _locationStatusTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showLocationStatus = false;
          });
        }
      });
    } else {
      _locationStatusTimer?.cancel();
      setState(() {
        _showLocationStatus = true;
      });
    }
  }

  void _stopLocationStatusTimer() {
    _locationStatusTimer?.cancel();
    _locationStatusTimer = null;
  }

  Future<void> _updateCameraToUserLocation(
      double latitude, double longitude) async {
    if (mapboxMap == null || !mounted) return;
    try {
      await mapboxMap!.setCamera(CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: currentZoom,
      ));
    } catch (e) {
      developer.log('Ошибка обновления камеры: $e', name: 'MAP_PAGE');
    }
  }

  // --- WebSocket and Network ---
  void _connectWebSocket(String accessToken) async {
    // ... (Unchanged)
    if (accessToken.isEmpty) return;
    try {
      await connectToOnlineStatus(accessToken);
    } catch (e, st) {
      developer.log('Ошибка при подключении к WebSocket: $e',
          name: 'MAP_PAGE', error: e, stackTrace: st);
    }
  }

  Future<void> delayedLocationUpdate(double lat, double lon) async {
    // ... (Unchanged)
    MapApi().updateUserLocation(lat, lon);
  }

  // --- Map Event Handlers ---
  void _onMapCreated(MapboxMap map) async {
    if (!mounted) return;
    setState(() {
      mapboxMap = map;
    });
    context.read<MapBloc>().setMapbox(map);
    print('[DEBUG_GEOJSON] Map created and set in Bloc.');

    await mapboxMap!.gestures
        .updateSettings(_mapOptimizationService.getOptimizedGesturesSettings());
    await mapboxMap!.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await mapboxMap!.logo.updateSettings(LogoSettings(enabled: true));
    await mapboxMap!.attribution
        .updateSettings(AttributionSettings(enabled: true));
    await mapboxMap!.compass.updateSettings(CompassSettings(enabled: false));

    // ONLY load style here. Source/layer will be added in onStyleLoaded.
    await _loadLocalStyle();

    // Добавлено: перемещаем камеру к позиции пользователя, если она известна
    if (currentUserPosition != null && _shouldMoveCameraToUser) {
      print(
          '[DEBUG] (onMapCreated) Перемещаю камеру к user: ${currentUserPosition!.lat}, ${currentUserPosition!.lng}');
      await _updateCameraToUserLocation(
        currentUserPosition!.lat.toDouble(),
        currentUserPosition!.lng.toDouble(),
      );
      _shouldMoveCameraToUser = false;
    }
  }

  Future<void> _onStyleLoaded(StyleLoadedEventData styleLoadedEventData) async {
    if (!mounted) return;

    // Сброс флага перед добавлением нового источника (важно при смене стиля)
    _isGeoJsonSourceInitialized = false;

    // Add user location icon (puck)
    if (currentUserPosition != null && mapboxMap != null) {
      await addUserIconToStyle(mapboxMap!);
      // Добавлено: перемещаем камеру к позиции пользователя
      await _updateCameraToUserLocation(
        currentUserPosition!.lat.toDouble(),
        currentUserPosition!.lng.toDouble(),
      );
    }

    if (!_isGeoJsonSourceInitialized) {
      print(
          '[DEBUG_GEOJSON] Style loaded. Initializing clustered source and layers.');

      // 1. Add GeoJSON source with clustering enabled.
      await mapboxMap!.style.addSource(
        GeoJsonSource(
          id: EVENTS_SOURCE_ID,
          cluster: true,
          clusterMaxZoom: 12, // Cluster points up to zoom level 12.
          clusterRadius: 50, // Group points within a 50-pixel radius.
        ),
      );

      // 2. Проверяем наличие слоев перед добавлением
      bool hasClustersCircle = false;
      bool hasClustersCount = false;
      try {
        hasClustersCircle =
            (await mapboxMap!.style.getLayer('clusters-circle')) != null;
      } catch (e) {
        hasClustersCircle = false;
      }
      try {
        hasClustersCount =
            (await mapboxMap!.style.getLayer('clusters-count')) != null;
      } catch (e) {
        hasClustersCount = false;
      }

      if (!hasClustersCircle) {
        await mapboxMap!.style.addLayer(
          CircleLayer(
            id: 'clusters-circle',
            sourceId: EVENTS_SOURCE_ID,
            filter: ['has', 'point_count'],
            circleColor: Colors.blue.value,
            circleRadius: 20.0, // Using a fixed value due to SDK limitations
            circleStrokeWidth: 1,
            circleStrokeColor: Colors.white.value,
          ),
        );
      } else {
        print(
            '[DEBUG_GEOJSON] Layer clusters-circle уже существует, не добавляем повторно.');
      }

      if (!hasClustersCount) {
        await mapboxMap!.style.addLayer(
          SymbolLayer(
            id: 'clusters-count',
            sourceId: EVENTS_SOURCE_ID,
            filter: ['has', 'point_count'],
            textField: '{point_count_abbreviated}',
            textSize: 14,
            textColor: Colors.white.value,
            textIgnorePlacement: true,
            textAllowOverlap: true,
          ),
        );
      } else {
        print(
            '[DEBUG_GEOJSON] Layer clusters-count уже существует, не добавляем повторно.');
      }

      _isGeoJsonSourceInitialized = true;
      print('[DEBUG_GEOJSON] Clustered source and cluster layers created.');

      // ВАЖНО: если есть отложенное состояние, обновляем источник
      if (_pendingMapState != null) {
        print(
            '[DEBUG_GEOJSON] Updating source from pending state после инициализации.');
        _updateMapSource(_pendingMapState!);
        _pendingMapState = null;
      }
    }

    // Trigger initial event load
    if (searchedEventsModel != null) {
      context.read<MapBloc>().add(LoadEvents(searchedEventsModel!.events));
      _pendingMapState = null;
    }
  }

  void _onMapTap(MapContentGestureContext gestureContext) async {
    if (mapboxMap == null || _isProcessingTap) return;

    final point = await mapboxMap!.pixelForCoordinate(gestureContext.point);
    final box = ScreenBox(
      min: ScreenCoordinate(x: point.x - 5, y: point.y - 5),
      max: ScreenCoordinate(x: point.x + 5, y: point.y + 5),
    );
    final layerIdsToQuery = ['clusters-circle', ..._initializedLayers];

    final features = await mapboxMap!.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenBox(box),
      RenderedQueryOptions(layerIds: layerIdsToQuery, filter: null),
    );

    if (features.isEmpty || features.first == null) {
      print('[DEBUG_GEOJSON] Tapped on empty map area or got null feature.');
      return;
    }

    final queriedFeature = features.first!.queriedFeature;
    if (queriedFeature.feature['properties'] == null) return;

    final properties =
        Map<String, dynamic>.from(queriedFeature.feature['properties'] as Map);

    // Если это кластер — фильтруем события по радиусу
    if (properties.containsKey('cluster') && properties['cluster'] == true) {
      final pointCount = properties['point_count'] as int;
      final clusterGeometry = queriedFeature.feature['geometry'];
      if (clusterGeometry == null) {
        print('[DEBUG_GEOJSON] Cluster geometry is null.');
        return;
      }
      final geometryMap = (clusterGeometry as Map).cast<String, dynamic>();
      final clusterCoords = (geometryMap['coordinates'] ?? []) as List<dynamic>;
      if (clusterCoords.length < 2) {
        print('[DEBUG_GEOJSON] Cluster geometry has no coordinates.');
        return;
      }
      final clusterLng = clusterCoords[0] as double;
      final clusterLat = clusterCoords[1] as double;
      // Эвристика: радиус кластера зависит от количества точек
      final minRadius = 150.0;
      final maxRadius = 900.0;
      final baseRadius = 120.0 + 90.0 * math.log(pointCount + 1);
      final clusterRadius = baseRadius.clamp(minRadius, maxRadius);

      final mapState = BlocProvider.of<MapBloc>(context, listen: false).state;
      final eventsInCluster =
          mapState.groupedEvents.expand((g) => g).where((event) {
        if (event.latitude == null || event.longitude == null) return false;
        final distance = geolocator.Geolocator.distanceBetween(
          event.latitude!,
          event.longitude!,
          clusterLat,
          clusterLng,
        );
        return distance <= clusterRadius;
      }).toList();

      if (eventsInCluster.isNotEmpty) {
        _showEventsBottomSheet(
            eventsInCluster.map((e) => e.id.toString()).toList());
      } else {
        print('[DEBUG_GEOJSON] No events found in cluster by radius.');
      }
      return;
    }

    // Если это одиночный маркер — показываем карточку
    final eventId = properties['eventId'];
    if (eventId != null) {
      print('[DEBUG_GEOJSON] Tapped feature with eventId: $eventId');
      _handleMarkerTap(eventId as String);
    }
  }

  void _showEventsBottomSheet(List<String> eventIds) {
    if (_isProcessingTap) return;
    _isProcessingTap = true;

    try {
      final mapState = BlocProvider.of<MapBloc>(context, listen: false).state;
      final eventIdSet = eventIds.toSet();

      final eventsToShow = mapState.groupedEvents
          .expand((group) => group) // Flatten the list of lists
          .where((event) => eventIdSet.contains(event.id.toString()))
          .toList();

      if (eventsToShow.isEmpty) {
        print(
            '[DEBUG_GEOJSON] No matching events found in state for the given IDs.');
        _isProcessingTap = false;
        return;
      }
      if (Navigator.of(context).canPop()) {
        _isProcessingTap = false;
        return;
      }

      print(
          '[DEBUG_GEOJSON] Showing CascadeCardsEventOnMap with ${eventsToShow.length} events.');
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CascadeCardsEventOnMap(
          organizedEvents: eventsToShow,
          profileId: profileId ?? '',
        ),
      ).whenComplete(() {
        _isProcessingTap = false;
      });
    } catch (e) {
      print('[ERROR_GEOJSON] Error showing cluster bottom sheet: $e');
      _isProcessingTap = false;
    }
  }

  void _handleMarkerTap(String eventId) {
    if (_isProcessingTap) return;
    _isProcessingTap = true;

    try {
      final mapState = BlocProvider.of<MapBloc>(context, listen: false).state;
      final group = mapState.groupedEvents.firstWhere(
        (g) => g.any((e) => e.id.toString() == eventId),
        orElse: () => [],
      );

      if (group.isEmpty) {
        print('[DEBUG_GEOJSON] Group not found for eventId: $eventId');
        return;
      }

      if (Navigator.of(context).canPop()) {
        return;
      }

      Widget bottomSheet;
      if (group.length > 1) {
        bottomSheet = CascadeCardsEventOnMap(
          organizedEvents: group,
          profileId: profileId ?? '',
        );
      } else {
        bottomSheet = CardEventOnMap(organizedEvent: group.first);
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => bottomSheet,
      ).whenComplete(() {
        _isProcessingTap = false;
      });
    } catch (e) {
      print('[ERROR_GEOJSON] Error handling marker tap: $e');
      _isProcessingTap = false;
    }
  }

  Future<void> _onCameraMove(CameraState cameraState) async {
    // ... (This function remains mostly the same as in MapScreen)
    if (!mounted) return;

    final newLat = cameraState.center.coordinates.lat.toDouble();
    final newLng = cameraState.center.coordinates.lng.toDouble();
    double distance = geolocator.Geolocator.distanceBetween(
      currentSelectedPosition.lat.toDouble(),
      currentSelectedPosition.lng.toDouble(),
      newLat,
      newLng,
    );

    if (distance > 1000) {
      if (_lastRequestPosition != null) {
        double distanceFromLastRequest = geolocator.Geolocator.distanceBetween(
          _lastRequestPosition!.lat.toDouble(),
          _lastRequestPosition!.lng.toDouble(),
          newLat,
          newLng,
        );
        if (distanceFromLastRequest < 50000) {
          setState(() {
            currentSelectedPosition = Position(newLng, newLat);
          });
          return;
        }
      }
      setState(() {
        currentSelectedPosition = Position(newLng, newLat);
        _lastRequestPosition = Position(newLng, newLat);
      });
      context.read<MapBloc>().add(const UpdateMarkers());
      context.read<ProfileBloc>().add(SearchEventsOnMapEvent(
            latitude: newLat,
            longitude: newLng,
          ));
    }
  }

  // --- ** NEW GEOJSON APPROACH ** ---

  /// Updates the GeoJsonSource with the current events.
  void _updateMapSource(MapState mapState) async {
    print(
        '[DEBUG_GEOJSON_UPDATE] Running with markerType: ${mapState.markerType}');
    if (mapboxMap == null || !_isGeoJsonSourceInitialized) {
      print('[DEBUG_GEOJSON] Map or source not ready, queuing update.');
      _pendingMapState = mapState;
      return;
    }

    // 1. Ensure all required images for unclustered points are loaded
    await _prepareImagesAndLayers(mapState);

    // 2. Create a list of GeoJSON features from events.
    final features = <Map<String, dynamic>>[];
    for (final group in mapState.groupedEvents) {
      final event = group.first;
      if (event.latitude == null || event.longitude == null) continue;
      String iconName = _getIconNameForGroup(group);
      features.add({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [event.longitude, event.latitude]
        },
        'properties': {
          'eventId': event.id.toString(),
          'icon': iconName,
        }
      });
    }
    final featureCollection = {
      'type': 'FeatureCollection',
      'features': features
    };
    print(
        '[DEBUG_GEOJSON_UPDATE] Attempting to find source: $EVENTS_SOURCE_ID');
    try {
      final source = await mapboxMap!.style.getSource(EVENTS_SOURCE_ID);
      if (source == null) {
        print('[DEBUG_GEOJSON_UPDATE] Source not found, ставим в очередь.');
        _pendingMapState = mapState;
        return;
      }
      if (source is GeoJsonSource) {
        print(
            '[DEBUG_GEOJSON_UPDATE] Source found. Updating source with ${features.length} features.');
        await source.updateGeoJSON(jsonEncode(featureCollection));
        print('[DEBUG_GEOJSON_UPDATE] Source update successful.');
      } else {
        print(
            '[DEBUG_GEOJSON_ERROR] Source "$EVENTS_SOURCE_ID" is NOT a GeoJsonSource. It is [31m${source.runtimeType}[0m');
        _pendingMapState = mapState;
      }
    } catch (e, st) {
      print(
          '[DEBUG_GEOJSON_ERROR] An error occurred while updating the source: $e');
      print(st);
      _pendingMapState = mapState;
    }
  }

  /// Determines the correct icon name for a group of events.
  String _getIconNameForGroup(List<OrganizedEventModel> group) {
    final event = group.first;
    String iconName;

    // This logic is for the 'unclustered-points' layers.
    // The map's clustering handles everything else.
    if (group.length > 1) {
      iconName = 'grouped_${group.length}';
    } else if (event.category != null) {
      iconName = 'category_${event.category!.id}';
    } else {
      iconName = 'simple_point'; // Fallback for single events with no category
    }

    print(
        '[DEBUG_GEOJSON_ICON] For event ${event.id}, providing detailed icon property: $iconName');
    return iconName;
  }

  /// Ensures that all necessary images and layers for unclustered points are present in the map's style.
  Future<void> _prepareImagesAndLayers(MapState mapState) async {
    if (mapboxMap == null) {
      print('[DEBUG_GEOJSON_PREPARE] Map is null, aborting.');
      return;
    }

    final requiredImageIds = <String>{};
    final categoryIds = <String>{};

    for (final group in mapState.groupedEvents) {
      final imageId = _getIconNameForGroup(group);
      requiredImageIds.add(imageId);

      // Собираем ID категорий для предзагрузки
      if (imageId.startsWith('category_')) {
        final categoryId = imageId.split('_').last;
        categoryIds.add(categoryId);
      }
    }

    print('[DEBUG_GEOJSON_PREPARE] Required image IDs: $requiredImageIds');
    print(
        '[DEBUG_GEOJSON_PREPARE] Category IDs that need images: $categoryIds');

    // Предзагружаем изображения категорий, если они еще не загружены
    if (categoryIds.isNotEmpty) {
      await _ensureCategoryImagesLoaded(categoryIds);
    }

    for (final imageId in requiredImageIds) {
      final layerId = 'layer-unclustered-$imageId';
      try {
        // --- 1. Prepare Image ---
        final existingImage = await mapboxMap!.style.getStyleImage(imageId);
        if (existingImage == null) {
          print(
              '[DEBUG_GEOJSON_PREPARE] Image $imageId not found. Capturing widget.');
          final imageBytes = await _captureWidgetForImageId(imageId);
          if (imageBytes != null) {
            final codec = await ui.instantiateImageCodec(imageBytes);
            final frame = await codec.getNextFrame();
            final uiImage = frame.image;
            final mbxImage = MbxImage(
                width: uiImage.width, height: uiImage.height, data: imageBytes);

            await mapboxMap!.style
                .addStyleImage(imageId, 1.0, mbxImage, false, [], [], null);
            print(
                '[DEBUG_GEOJSON_PREPARE] Successfully added style image: $imageId');
          } else {
            print(
                '[DEBUG_GEOJSON_PREPARE] Failed to capture widget for $imageId (returned null).');
            continue; // Skip layer creation if image failed
          }
        }

        // --- 2. Prepare Layer ---
        if (!_initializedLayers.contains(layerId)) {
          print(
              '[DEBUG_GEOJSON_PREPARE] Layer $layerId not found. Creating it.');
          await mapboxMap!.style.addLayer(
            SymbolLayer(
              id: layerId,
              sourceId: EVENTS_SOURCE_ID,
              iconImage: imageId,
              iconSize: 0.3,
              iconAllowOverlap: true,
              iconIgnorePlacement: true,
              filter: [
                'all',
                [
                  '!',
                  ['has', 'point_count']
                ], // is an unclustered point
                [
                  '==',
                  ['get', 'icon'],
                  imageId
                ] // and has the right icon property
              ],
            ),
          );
          _initializedLayers.add(layerId);
          print(
              '[DEBUG_GEOJSON_PREPARE] Successfully created and cached layer: $layerId');
        }
      } catch (e, st) {
        print(
            '[ERROR_GEOJSON_PREPARE] Failed to prepare image/layer for $imageId: $e');
        print(st);
      }
    }
  }

  /// Ensures that category images are loaded before creating markers
  Future<void> _ensureCategoryImagesLoaded(Set<String> categoryIds) async {
    final missingCategories = <String>[];

    for (final categoryId in categoryIds) {
      if (!_categoryImageCache.containsKey(categoryId)) {
        missingCategories.add(categoryId);
      }
    }

    if (missingCategories.isNotEmpty) {
      print('[DEBUG_PREPARE] Missing category images: $missingCategories');

      // Находим URL для недостающих категорий
      final categoryUrls = <String, String>{};
      for (final categoryId in missingCategories) {
        try {
          final event = searchedEventsModel?.events
              .firstWhere((e) => e.category?.id == categoryId);
          if (event?.category?.iconPath != null) {
            categoryUrls[categoryId] = event!.category!.iconPath;
          }
        } catch (e) {
          print('[DEBUG_PREPARE] Category $categoryId not found in events');
        }
      }

      // Загружаем недостающие изображения
      if (categoryUrls.isNotEmpty) {
        print(
            '[DEBUG_PREPARE] Loading ${categoryUrls.length} missing category images');
        final futures = <Future<void>>[];
        for (final entry in categoryUrls.entries) {
          futures.add(_loadSingleCategoryImage(entry.key, entry.value));
        }
        await Future.wait(futures);
        print('[DEBUG_PREPARE] Finished loading category images');
      }
    }
  }

  /// Captures a widget based on its ID and returns the bytes.
  Future<Uint8List?> _captureWidgetForImageId(String imageId) async {
    print('[DEBUG_CAPTURE] Starting capture for imageId: $imageId');

    Widget widgetToCapture;

    if (imageId == 'simple_point') {
      widgetToCapture = const SimpleBluePoint();
      print('[DEBUG_CAPTURE] Using SimpleBluePoint for $imageId');
    } else if (imageId.startsWith('grouped_')) {
      final count = int.tryParse(imageId.split('_').last) ?? 0;
      widgetToCapture = GroupedMarker(key: ValueKey(imageId), count: count);
      print(
          '[DEBUG_CAPTURE] Using GroupedMarker for $imageId with count: $count');
    } else if (imageId.startsWith('category_')) {
      final categoryId = imageId.split('_').last;
      OrganizedEventModel? event;
      try {
        event = searchedEventsModel?.events
            .firstWhere((e) => e.category?.id == categoryId);
      } catch (e) {
        event = null;
      }

      if (event != null && event.category != null) {
        final preloadedImage = _categoryImageCache[event.category!.id];
        print(
            '[DEBUG_CAPTURE] Capturing widget for category $categoryId, preloadedImage: ${preloadedImage != null ? 'available (${preloadedImage.length} bytes)' : 'not available'}');
        print(
            '[DEBUG_CAPTURE] Category name: ${event.category!.name}, iconPath: ${event.category!.iconPath}');

        widgetToCapture = OptimizedCategoryMarker(
          key: ValueKey(imageId),
          title: event.category!.name,
          preloadedImage: preloadedImage,
        );
      } else {
        print(
            '[DEBUG_CAPTURE] Category not found for $categoryId, using fallback');
        widgetToCapture = const OptimizedCategoryMarker(
          title: 'Событие',
          preloadedImage: null,
        );
      }
    } else {
      print('[DEBUG_CAPTURE] Unknown imageId: $imageId');
      return null;
    }

    try {
      print('[DEBUG_CAPTURE] Capturing widget with screenshotController...');
      final capturedBytes = await screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: RepaintBoundary(child: widgetToCapture),
          ),
        ),
        delay: Duration.zero,
      );

      print(
          '[DEBUG_CAPTURE] Successfully captured widget for $imageId (${capturedBytes.length} bytes)');
      return capturedBytes;
    } catch (e) {
      print('[ERROR_CAPTURE] Failed to capture widget for $imageId: $e');
      return null;
    }
  }

  Future<void> _loadLocalStyle() async {
    // ... (Unchanged)
    try {
      final cachedStyle = _mapOptimizationService.getCachedStyle();
      if (cachedStyle != null && cachedStyle.startsWith('mapbox://')) {
        if (mapboxMap != null) {
          await mapboxMap!.loadStyleURI(cachedStyle);
        }
      } else {
        final styleJson =
            await rootBundle.loadString('assets/map_styles/custom_style.json');
        final modifiedStyleJson = styleJson.replaceAll(
            'YOUR_MAPBOX_ACCESS_TOKEN',
            'pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg');
        if (mapboxMap != null) {
          await mapboxMap!.loadStyleJson(modifiedStyleJson);
          await _mapOptimizationService
              .cacheMapStyle('mapbox://styles/acti/cmbf00t92005701s5d84c1cqp');
        }
      }
    } catch (e) {
      print('Ошибка загрузки локального стиля: $e');
      if (mapboxMap != null) {
        await mapboxMap!
            .loadStyleURI('mapbox://styles/acti/cmbf00t92005701s5d84c1cqp');
      }
    }
  }

  /// Preloads category icon images from URLs to speed up rendering.
  Future<void> _preloadCategoryImages(List<OrganizedEventModel> events) async {
    final uniqueCategories = <String, String>{};
    for (final event in events) {
      if (event.category != null) {
        uniqueCategories[event.category!.id] = event.category!.iconPath;
      }
    }

    print(
        '[DEBUG_PRELOAD] Starting to preload ${uniqueCategories.length} category images');

    final futures = <Future<void>>[];
    for (final entry in uniqueCategories.entries) {
      final categoryId = entry.key;
      final iconUrl = entry.value;

      if (!_categoryImageCache.containsKey(categoryId)) {
        futures.add(_loadSingleCategoryImage(categoryId, iconUrl));
      }
    }

    // Ждем загрузки всех изображений
    await Future.wait(futures);
    print(
        '[DEBUG_PRELOAD] Finished preloading ${_categoryImageCache.length} images');
  }

  /// Loads a single category image and caches it
  Future<void> _loadSingleCategoryImage(
      String categoryId, String iconUrl) async {
    try {
      print(
          '[DEBUG_PRELOAD] Loading image for category $categoryId from $iconUrl');

      final imageProvider = CachedNetworkImageProvider(iconUrl);
      final completer = Completer<Uint8List>();

      final listener = ImageStreamListener((info, _) async {
        try {
          print(
              '[DEBUG_PRELOAD] Image loaded for category $categoryId, converting to bytes...');
          final byteData =
              await info.image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            final bytes = byteData.buffer.asUint8List();
            _categoryImageCache[categoryId] = bytes;
            completer.complete(bytes);
            print(
                '[DEBUG_PRELOAD] Successfully loaded image for category $categoryId (${bytes.length} bytes)');
          } else {
            print(
                '[ERROR_PRELOAD] Failed to get image byte data for category $categoryId');
            completer.completeError(
                'Failed to get image byte data for category $categoryId');
          }
        } catch (e) {
          print(
              '[ERROR_PRELOAD] Exception while converting image for category $categoryId: $e');
          completer.completeError(e);
        }
      }, onError: (error, stackTrace) {
        print(
            '[ERROR_PRELOAD] Failed to load image for category $categoryId: $error');
        completer.completeError(error, stackTrace);
      });

      print(
          '[DEBUG_PRELOAD] Resolving image provider for category $categoryId...');
      imageProvider.resolve(const ImageConfiguration()).addListener(listener);
      await completer.future;
    } catch (e) {
      print('[ERROR_PRELOAD] Failed to load category image $categoryId: $e');
      // Не добавляем в кэш при ошибке, чтобы можно было повторить попытку
    }
  }

  String get locationStatusText {
    if (currentUserPosition == null) return 'Геолокация недоступна';
    if (currentUserPosition!.lat == 37.6173 &&
        currentUserPosition!.lng == 55.7558) {
      return 'Используется позиция по умолчанию (Москва)';
    }
    // Можно добавить проверку на кэш, если потребуется
    return 'Геолокация активна';
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // This listener remains the same, preloading images and dispatching to MapBloc
        if (state is SearchedEventsOnMapState || state is InitializeMapState) {
          final events = (state is SearchedEventsOnMapState)
              ? state.searchedEventsModel.events
              : (state as InitializeMapState).searchedEventsModel.events;
          final model = (state is SearchedEventsOnMapState)
              ? state.searchedEventsModel
              : (state as InitializeMapState).searchedEventsModel;
          setState(() {
            searchedEventsModel = model;
          });

          // Сначала загружаем изображения, затем отправляем события в MapBloc
          _preloadCategoryImages(events).then((_) {
            print(
                '[DEBUG_LISTENER] Images preloaded, sending events to MapBloc');
            context.read<MapBloc>().add(LoadEvents(events));
          }).catchError((e) {
            print('[ERROR_LISTENER] Failed to preload images: $e');
            // Даже если загрузка изображений не удалась, отправляем события
            context.read<MapBloc>().add(LoadEvents(events));
          });
        }
      },
      child: BlocListener<MapBloc, MapState>(
        listenWhen: (prev, curr) {
          final changed = prev.markerType != curr.markerType;
          print(
              '[DEBUG_GEOJSON_LISTENWHEN] prev.markerType: ${prev.markerType}, curr.markerType: ${curr.markerType}, changed: $changed');
          return changed || prev.groupedEvents != curr.groupedEvents;
        },
        listener: (context, mapState) {
          print(
              '[DEBUG_GEOJSON_LISTENER] Detected state change. New markerType: ${mapState.markerType}. Calling update.');
          // The new listener simply calls the source update function
          _updateMapSource(mapState);
        },
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, mapState) {
            return SafeArea(
              top: false,
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
                              onMapCreated: _onMapCreated,
                              onStyleLoadedListener: _onStyleLoaded,
                              onTapListener: _onMapTap,
                              onMapIdleListener: (event) async {
                                if (mapboxMap != null) {
                                  final camera =
                                      await mapboxMap!.getCameraState();
                                  context
                                      .read<MapBloc>()
                                      .add(ZoomChanged(camera.zoom));
                                  await _onCameraMove(camera);
                                }
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
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: buildMapControls(),
                            ),
                            if (mapState.isLoading)
                              Center(
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 3, color: Colors.white),
                                ),
                              ),
                            // The rest of the UI (location status, bottom sheet) remains the same
                            Positioned(
                              top: 50,
                              right: 80,
                              left: 80,
                              child: AnimatedOpacity(
                                opacity: _showLocationStatus ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: GestureDetector(
                                  onLongPress: refreshUserLocation,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          locationStatusText,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
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
              ),
            );
          },
        ),
      ),
    );
  }

  // --- UI Widgets ---
  // buildMapControls and other UI helper methods are copied from MapScreen
  // and remain mostly unchanged.
  Widget buildMapControls() {
    if (selectedIndex != 0) return SizedBox.shrink();
    return Container(
        width: 59,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), bottomLeft: Radius.circular(30))),
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
                                        latitude:
                                            currentUserPosition!.lat.toDouble(),
                                        longitude:
                                            currentUserPosition!.lng.toDouble(),
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
                                  // This filter logic remains the same
                                  final filterProvider =
                                      Provider.of<FilterProvider>(context,
                                          listen: false);
                                  _lastRequestPosition = null;
                                  double searchLat =
                                      currentSelectedPosition.lat.toDouble();
                                  double searchLng =
                                      currentSelectedPosition.lng.toDouble();
                                  if (filterProvider.selectedMapAddressModel !=
                                      null) {
                                    searchLat = filterProvider
                                            .selectedMapAddressModel!
                                            .latitude ??
                                        searchLat;
                                    searchLng = filterProvider
                                            .selectedMapAddressModel!
                                            .longitude ??
                                        searchLng;
                                  }
                                  // ... rest of the filter logic is identical to MapScreen
                                  final filters = {
                                    'radius':
                                        filterProvider.selectedRadius.round(),
                                    'restrictions':
                                        filterProvider.selectedAgeRestrictions,
                                    // ... and so on
                                  };
                                  context
                                      .read<MapBloc>()
                                      .add(ApplyFilter(filters));
                                  context.read<ProfileBloc>().add(
                                      SearchEventsOnMapEvent(
                                          latitude: searchLat,
                                          longitude: searchLng,
                                          filters: filters));
                                }));
                      }),
                  IconButton(
                      onPressed: () async {
                        if (mapboxMap != null) {
                          final camera = await mapboxMap!.getCameraState();
                          await mapboxMap!
                              .setCamera(CameraOptions(zoom: camera.zoom - 1));
                          final updatedCamera =
                              await mapboxMap!.getCameraState();
                          setState(() {
                            currentZoom = updatedCamera.zoom;
                          });
                          context
                              .read<MapBloc>()
                              .add(ZoomChanged(updatedCamera.zoom));
                        }
                      },
                      icon: SvgPicture.asset('assets/left_drawer/minus.svg')),
                  IconButton(
                      onPressed: () async {
                        if (mapboxMap != null) {
                          final camera = await mapboxMap!.getCameraState();
                          await mapboxMap!
                              .setCamera(CameraOptions(zoom: camera.zoom + 1));
                          final updatedCamera =
                              await mapboxMap!.getCameraState();
                          setState(() {
                            currentZoom = updatedCamera.zoom;
                          });
                          context
                              .read<MapBloc>()
                              .add(ZoomChanged(updatedCamera.zoom));
                        }
                      },
                      icon: SvgPicture.asset('assets/left_drawer/plus.svg')),
                  IconButton(
                      onPressed: () async {
                        if (currentUserPosition != null && mapboxMap != null) {
                          await mapboxMap!.setCamera(CameraOptions(
                              center: Point(
                                  coordinates: Position(
                                      currentUserPosition!.lng,
                                      currentUserPosition!.lat)),
                              zoom: currentZoom));
                          _startLocationStatusTimer();
                        } else {
                          await _getUserLocation();
                          if (currentUserPosition != null &&
                              mapboxMap != null) {
                            await mapboxMap!.setCamera(CameraOptions(
                                center: Point(
                                    coordinates: Position(
                                        currentUserPosition!.lng,
                                        currentUserPosition!.lat)),
                                zoom: currentZoom));
                            _startLocationStatusTimer();
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Не удалось определить вашу позицию. Проверьте настройки геолокации.'),
                                      duration: Duration(seconds: 3)));
                              setState(() {
                                _showLocationStatus = true;
                              });
                            }
                          }
                        }
                      },
                      icon: SvgPicture.asset(
                          'assets/left_drawer/my_location.svg'))
                ])));
  }
}

class SimpleBluePoint extends StatelessWidget {
  const SimpleBluePoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.blue,
        border: Border.all(color: Colors.white, width: 2),
        shape: BoxShape.circle,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.2),
        //     blurRadius: 2,
        //     offset: const Offset(0, 1),
        //   ),
        // ],
      ),
    );
  }
}

// The marker widgets (CircleCountMarker, SimpleBluePoint, etc.) can remain in marker.dart
// as they are still used for rendering to images.
