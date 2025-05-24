import 'package:acti_mobile/data/models/mapbox_reverse_model.dart';

class LocalAddressModel {
  final String? address;
  final double? latitude;
  final double? longitude;
  final Properties? properties;

  LocalAddressModel({required this.address, required this.latitude, required this.longitude,
  required this.properties,});
}