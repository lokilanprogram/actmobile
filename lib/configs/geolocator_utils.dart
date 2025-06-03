import 'package:geotypes/src/geojson.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

const _defaultLatitude = 55.7558;
const _defaultLongitude = 37.6173;

Future<bool> checkGeolocator() async {
  final serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
  return serviceEnabled;
}

Future<Position> getPosition() async {
  if (await checkGeolocator()) {
    final position = await geolocator.Geolocator.getCurrentPosition();
    return Position(position.longitude, position.latitude);
  } else {
    return Position(_defaultLongitude, _defaultLatitude);
  }
}

Future<Position> getCurrentUserPosition() async {
  final position = await geolocator.Geolocator.getCurrentPosition();
  return Position(position.longitude, position.latitude);
}
