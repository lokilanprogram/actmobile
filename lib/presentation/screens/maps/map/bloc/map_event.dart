import 'package:equatable/equatable.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

class LoadEvents extends MapEvent {
  final List<OrganizedEventModel> events;
  const LoadEvents(this.events);
  @override
  List<Object?> get props => [events];
}

class ZoomChanged extends MapEvent {
  final double zoom;
  const ZoomChanged(this.zoom);
  @override
  List<Object?> get props => [zoom];
}

class UpdateMarkers extends MapEvent {
  const UpdateMarkers();
}

class ApplyFilter extends MapEvent {
  final Map<String, dynamic> filters;
  const ApplyFilter(this.filters);
  @override
  List<Object?> get props => [filters];
}
