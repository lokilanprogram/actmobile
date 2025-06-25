import 'package:flutter_bloc/flutter_bloc.dart';
import 'map_event.dart';
import 'map_state.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'dart:math' as math;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class _EventWithScreen {
  final OrganizedEventModel event;
  final ScreenCoordinate screen;
  _EventWithScreen(this.event, this.screen);
}

class MapBloc extends Bloc<MapEvent, MapState> {
  MapboxMap? mapboxMap;
  int _markerVersion = 0;

  // Кэш для кластеров по зуму
  final Map<int, List<List<OrganizedEventModel>>> _zoomClusterCache = {};
  List<OrganizedEventModel> _lastEvents = [];

  // Кэшируем ответ сервера
  List<OrganizedEventModel> _serverEventsCache = [];

  MapBloc({this.mapboxMap}) : super(const MapState()) {
    on<LoadEvents>(_onLoadEvents);
    on<ZoomChanged>(_onZoomChanged);
    on<UpdateMarkers>(_onUpdateMarkers);
    on<ApplyFilter>(_onApplyFilter);
  }

  void setMapbox(MapboxMap map) {
    mapboxMap = map;
    print('[DEBUG] MapBloc: mapboxMap установлен');
  }

  void _onLoadEvents(LoadEvents event, Emitter<MapState> emit) async {
    _markerVersion++;
    final currentVersion = _markerVersion;
    emit(state.copyWith(isLoading: true));
    _serverEventsCache = List.from(event.events); // Кэшируем ответ сервера

    // Считаем кластеры для всех зумов заранее
    for (final z in [6, 8, 10, 12, 14, 16, 18]) {
      _zoomClusterCache[z] =
          _groupEventsByGrid(_serverEventsCache, z.toDouble());
    }

    if (currentVersion != _markerVersion) return;
    // Берём группы для текущего зума
    final grouped = _zoomClusterCache[state.zoom.round()] ??
        _groupEventsByGrid(_serverEventsCache, state.zoom);
    emit(state.copyWith(isLoading: false, groupedEvents: grouped));
  }

  void _onZoomChanged(ZoomChanged event, Emitter<MapState> emit) async {
    _markerVersion++;
    final currentVersion = _markerVersion;
    emit(state.copyWith(zoom: event.zoom, isLoading: true));
    // Берём группы из кэша
    final grouped = _zoomClusterCache[event.zoom.round()] ??
        _groupEventsByGrid(_serverEventsCache, event.zoom);
    if (currentVersion != _markerVersion) return;
    emit(state.copyWith(isLoading: false, groupedEvents: grouped));
  }

  void _onUpdateMarkers(UpdateMarkers event, Emitter<MapState> emit) async {
    _markerVersion++;
    final currentVersion = _markerVersion;
    emit(state.copyWith(isLoading: true));
    final grouped = await _groupEventsByScreenPixels(
        _flatten(state.groupedEvents), state.zoom);
    if (currentVersion != _markerVersion) {
      print(
          '[DEBUG] MapBloc: отменяю устаревшую кластеризацию (UpdateMarkers)');
      return;
    }
    emit(state.copyWith(isLoading: false, groupedEvents: grouped));
  }

  void _onApplyFilter(ApplyFilter event, Emitter<MapState> emit) async {
    // Здесь можно реализовать фильтрацию событий по фильтрам
    // emit(state.copyWith(...));
  }

  // Функция для точной градации расстояния между маркерами по зуму
  double getCellSizeForZoom(double zoom) {
    if (zoom < 7) return 0.02;
    if (zoom < 9) return 0.01;
    if (zoom < 11) return 0.005;
    if (zoom < 13) return 0.002;
    if (zoom < 14) return 0.008;
    if (zoom < 15) return 0.0008;
    if (zoom < 17) return 0.0003;
    return 0.0001;
  }

  List<List<OrganizedEventModel>> _groupEventsByGridCached(
      List<OrganizedEventModel> events, double zoom) {
    final int zoomKey = zoom.round();
    // Если события не изменились и есть кэш — возвращаем кэш
    if (_lastEvents.length == events.length &&
        _lastEvents.every((e) => events.contains(e)) &&
        _zoomClusterCache.containsKey(zoomKey)) {
      return _zoomClusterCache[zoomKey]!;
    }
    // Если события изменились — сбрасываем кэш
    if (_lastEvents.length != events.length ||
        !_lastEvents.every((e) => events.contains(e))) {
      _zoomClusterCache.clear();
      _lastEvents = List.from(events);
    }
    // Кластеризация и кэширование
    final grouped = _groupEventsByGrid(events, zoom);
    _zoomClusterCache[zoomKey] = grouped;
    return grouped;
  }

  // Новая быстрая кластеризация по сетке (grid-based)
  List<List<OrganizedEventModel>> _groupEventsByGrid(
      List<OrganizedEventModel> events, double zoom) {
    final double cellSize = getCellSizeForZoom(zoom);
    final Map<String, List<OrganizedEventModel>> grid = {};
    for (final event in events) {
      if (event.latitude == null || event.longitude == null) continue;
      final latKey = (event.latitude! / cellSize).floor();
      final lngKey = (event.longitude! / cellSize).floor();
      final key = '\u001b[32m$latKey:$lngKey\u001b[0m';
      grid.putIfAbsent(key, () => []).add(event);
    }
    final result = grid.values.toList();
    print(
        '[DEBUG] MapBloc: сгруппировано кластеров (grid): \u001b[32m[32m${result.length}\u001b[0m');
    return result;
  }

  // Заменяем старую функцию на новую с кэшем
  Future<List<List<OrganizedEventModel>>> _groupEventsByScreenPixels(
      List<OrganizedEventModel> events, double zoom) async {
    return _groupEventsByGridCached(events, zoom);
  }

  List<OrganizedEventModel> _flatten(List<List<OrganizedEventModel>> groups) {
    return groups.expand((g) => g).toList();
  }
}
