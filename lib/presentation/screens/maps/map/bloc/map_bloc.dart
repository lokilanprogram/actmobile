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
    final grouped = await _groupEventsByScreenPixels(event.events, state.zoom);
    if (currentVersion != _markerVersion) {
      print('[DEBUG] MapBloc: отменяю устаревшую кластеризацию (LoadEvents)');
      return;
    }
    emit(state.copyWith(isLoading: false, groupedEvents: grouped));
  }

  void _onZoomChanged(ZoomChanged event, Emitter<MapState> emit) async {
    _markerVersion++;
    final currentVersion = _markerVersion;
    emit(state.copyWith(zoom: event.zoom, isLoading: true));
    final grouped = await _groupEventsByScreenPixels(
        _flatten(state.groupedEvents), event.zoom);
    if (currentVersion != _markerVersion) {
      print('[DEBUG] MapBloc: отменяю устаревшую кластеризацию (ZoomChanged)');
      return;
    }
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

  Future<List<List<OrganizedEventModel>>> _groupEventsByScreenPixels(
      List<OrganizedEventModel> events, double zoom) async {
    if (mapboxMap == null) {
      print('[DEBUG] MapBloc: mapboxMap == null, не могу кластеризовать');
      return [];
    }
    const double pixelRadius = 40;
    final List<_EventWithScreen> eventScreens = [];
    for (final event in events) {
      if (event.latitude == null || event.longitude == null) continue;
      final screen = await mapboxMap!.pixelForCoordinate(
        Point(coordinates: Position(event.longitude!, event.latitude!)),
      );
      eventScreens.add(_EventWithScreen(event, screen));
    }
    final List<List<_EventWithScreen>> groups = [];
    for (final ews in eventScreens) {
      bool added = false;
      for (final group in groups) {
        final first = group.first;
        final dx = (ews.screen.x - first.screen.x).abs();
        final dy = (ews.screen.y - first.screen.y).abs();
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist <= pixelRadius) {
          group.add(ews);
          added = true;
          break;
        }
      }
      if (!added) {
        groups.add([ews]);
      }
    }
    // Преобразуем обратно к событиям
    final result = groups.map((g) => g.map((e) => e.event).toList()).toList();
    print('[DEBUG] MapBloc: сгруппировано кластеров: ${result.length}');
    return result;
  }

  List<OrganizedEventModel> _flatten(List<List<OrganizedEventModel>> groups) {
    return groups.expand((g) => g).toList();
  }
}
