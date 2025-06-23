import 'package:equatable/equatable.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';

class MapState extends Equatable {
  final bool isLoading;
  final List<List<OrganizedEventModel>> groupedEvents;
  final double zoom;
  final String? error;

  const MapState({
    this.isLoading = false,
    this.groupedEvents = const [],
    this.zoom = 15.0,
    this.error,
  });

  MapState copyWith({
    bool? isLoading,
    List<List<OrganizedEventModel>>? groupedEvents,
    double? zoom,
    String? error,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      groupedEvents: groupedEvents ?? this.groupedEvents,
      zoom: zoom ?? this.zoom,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, groupedEvents, zoom, error];
}
