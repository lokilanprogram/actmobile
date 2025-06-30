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

  // Храним актуальные события с сервера
  final List<OrganizedEventModel> _currentEvents = [];

  // Кэш событий для отслеживания уже добавленных маркеров
  final Map<String, OrganizedEventModel> _eventsCache = {};

  // Флаг для отслеживания инициализации
  bool _isInitialized = false;

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

  /// Определяет тип маркеров на основе текущего зума
  String _getMarkerType(double zoom) {
    if (zoom < 11.0) {
      return 'simple';
    } else if (zoom < 13.0) {
      return 'grouped';
    } else {
      return 'detailed';
    }
  }

  void _onLoadEvents(LoadEvents event, Emitter<MapState> emit) async {
    _markerVersion++;
    final currentVersion = _markerVersion;
    emit(state.copyWith(isLoading: true));

    print('[DEBUG] ===== НАЧАЛО _onLoadEvents =====');
    print('[DEBUG] События с сервера (${event.events.length}):');
    for (final e in event.events) {
      print(
          '  id: \u001b[36m${e.id}\u001b[0m, lat: ${e.latitude}, lng: ${e.longitude}');
    }

    // Убираем дубликаты по координатам и создаем отдельные события
    final Map<String, OrganizedEventModel> uniqueEvents = {};
    for (final event in event.events) {
      if (event.latitude != null && event.longitude != null) {
        final coordKey = '${event.latitude}_${event.longitude}';
        if (!uniqueEvents.containsKey(coordKey)) {
          uniqueEvents[coordKey] = event;
        }
      }
    }

    // Определяем новые события и события для удаления
    final List<OrganizedEventModel> newEvents = [];
    final List<String> eventsToRemove = [];
    final List<OrganizedEventModel> allEvents = [];

    // Если кэш пустой (инициализация), все события считаются новыми
    if (_eventsCache.isEmpty) {
      print('[DEBUG] Инициализация - кэш пустой, все события считаются новыми');
      for (final event in uniqueEvents.values) {
        final eventId = event.id.toString();
        _eventsCache[eventId] = event;
        newEvents.add(event);
        allEvents.add(event);
        print(
            '[DEBUG] Событие для инициализации: \u001b[35m${event.id}\u001b[0m');
      }
      _isInitialized = true;
    } else {
      // Создаем множество ID новых событий для проверки
      final Set<String> newEventIds =
          uniqueEvents.values.map((e) => e.id.toString()).toSet();

      // Находим события, которые нужно удалить (есть в кэше, но нет в новых данных)
      for (final cachedEventId in _eventsCache.keys) {
        if (!newEventIds.contains(cachedEventId)) {
          eventsToRemove.add(cachedEventId);
          print(
              '[DEBUG] Событие для удаления: \u001b[31m$cachedEventId\u001b[0m');
        }
      }

      for (final event in uniqueEvents.values) {
        final eventId = event.id.toString();
        if (!_eventsCache.containsKey(eventId)) {
          // Новое событие - добавляем в кэш и в список новых
          _eventsCache[eventId] = event;
          newEvents.add(event);
          print('[DEBUG] Новое событие: \u001b[32m${event.id}\u001b[0m');
        } else {
          // Событие уже есть в кэше - обновляем его
          _eventsCache[eventId] = event;
          print('[DEBUG] Существующее событие: \u001b[34m${event.id}\u001b[0m');
        }
        allEvents.add(event);
      }

      // Удаляем события из кэша
      for (final eventId in eventsToRemove) {
        _eventsCache.remove(eventId);
      }
    }

    // Каждое уникальное событие - отдельная группа
    final grouped = allEvents.map((e) => [e]).toList();

    print('[DEBUG] Все события в кэше: ${_eventsCache.length}');
    print('[DEBUG] Новых событий: ${newEvents.length}');
    print('[DEBUG] Событий для удаления: ${eventsToRemove.length}');
    print('[DEBUG] Всего групп для отображения: ${grouped.length}');
    print('[DEBUG] ===== КОНЕЦ _onLoadEvents =====');

    if (currentVersion != _markerVersion) return;
    emit(state.copyWith(
      isLoading: false,
      groupedEvents: grouped,
      newEventIds: newEvents.map((e) => e.id.toString()).toList(),
      removedEventIds: eventsToRemove,
      markerType: _getMarkerType(state.zoom),
    ));
  }

  void _onZoomChanged(ZoomChanged event, Emitter<MapState> emit) async {
    _markerVersion++;
    final currentVersion = _markerVersion;
    final newZoom = event.zoom;
    final currentMarkerType = state.markerType;
    final newMarkerType = _getMarkerType(newZoom);

    print('[DEBUG] MapBloc: зум изменен с ${state.zoom} на $newZoom');
    print(
        '[DEBUG] MapBloc: тип маркеров изменен с $currentMarkerType на $newMarkerType');

    // Если тип маркеров изменился, пересоздаем их
    if (currentMarkerType != newMarkerType) {
      print('[DEBUG] MapBloc: пересоздаем маркеры из-за изменения типа');
      emit(state.copyWith(
        zoom: newZoom,
        markerType: newMarkerType,
        newEventIds: state.groupedEvents
            .map((group) => group.first.id.toString())
            .toList(),
        isLoading: true,
      ));
    } else {
      // Просто обновляем зум без пересоздания маркеров
      emit(state.copyWith(
        zoom: newZoom,
        markerType: newMarkerType,
        isLoading: false,
      ));
    }

    if (currentVersion != _markerVersion) return;
  }

  void _onUpdateMarkers(UpdateMarkers event, Emitter<MapState> emit) async {
    _markerVersion++;
    final currentVersion = _markerVersion;
    emit(state.copyWith(isLoading: true));

    // Очищаем кэш событий при смене области карты
    _eventsCache.clear();
    _isInitialized = false;
    print('[DEBUG] MapBloc: очищен кэш событий при смене области карты');

    // Просто обновляем состояние, не меняем структуру groupedEvents
    print('[DEBUG] MapBloc: обновление маркеров');
    if (currentVersion != _markerVersion) {
      print('[DEBUG] MapBloc: отменяю устаревшее обновление (UpdateMarkers)');
      return;
    }
    emit(state.copyWith(isLoading: false));
  }

  void _onApplyFilter(ApplyFilter event, Emitter<MapState> emit) async {
    // Очищаем кэш событий при применении фильтров
    _eventsCache.clear();
    _isInitialized = false;
    print('[DEBUG] MapBloc: очищен кэш событий при применении фильтров');

    // Здесь можно реализовать фильтрацию событий по фильтрам
    // emit(state.copyWith(...));
  }
}
