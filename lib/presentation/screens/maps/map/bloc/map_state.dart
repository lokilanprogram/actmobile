import 'package:equatable/equatable.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';

class MapState extends Equatable {
  final bool isLoading;
  final List<List<OrganizedEventModel>> groupedEvents;
  final double zoom;
  final String? error;
  final List<String> newEventIds;
  final List<String> removedEventIds;
  final String markerType; // 'simple', 'grouped', 'detailed'

  const MapState({
    this.isLoading = false,
    this.groupedEvents = const [],
    this.zoom = 15.0,
    this.error,
    this.newEventIds = const [],
    this.removedEventIds = const [],
    this.markerType = 'detailed',
  });

  MapState copyWith({
    bool? isLoading,
    List<List<OrganizedEventModel>>? groupedEvents,
    double? zoom,
    String? error,
    List<String>? newEventIds,
    List<String>? removedEventIds,
    String? markerType,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      groupedEvents: groupedEvents ?? this.groupedEvents,
      zoom: zoom ?? this.zoom,
      error: error,
      newEventIds: newEventIds ?? this.newEventIds,
      removedEventIds: removedEventIds ?? this.removedEventIds,
      markerType: markerType ?? this.markerType,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        groupedEvents,
        zoom,
        error,
        newEventIds,
        removedEventIds,
        markerType
      ];
}
