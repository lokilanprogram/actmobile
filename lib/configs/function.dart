  import 'package:acti_mobile/domain/screens/maps/map/widgets/card_event_on_map.dart';
import 'package:acti_mobile/domain/screens/maps/map/widgets/events_home_widget.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<void> addUserIconToStyle(MapboxMap mapboxMap) async {
  final ByteData bytes = await rootBundle.load('assets/icons/icon_current_location.png');
  final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  final ui.Image image = frame.image;

  // Преобразуем ui.Image → MbxImage
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return;

  final Uint8List imageBytes = byteData.buffer.asUint8List();

  final mbxImage = MbxImage(
    width: image.width,
    height:image.height,
    data: imageBytes,
  );

  // Добавляем изображение в стиль карты
  await mapboxMap.style.addStyleImage(
    'custom-user-icon', // imageId
    1, // scale
    mbxImage,
    false, // sdf (если true — будет воспринимать как монохромную иконку)
    [], // stretchX
    [], // stretchY
    null, // content
  );

  // Устанавливаем пользовательскую иконку
  await mapboxMap.location.updateSettings(
    LocationComponentSettings(
      enabled: true,
      locationPuck: LocationPuck(
        locationPuck2D: LocationPuck2D(
        bearingImage: imageBytes,
        topImage: imageBytes
      ),
      )
    ),
  );
  }
  void showCardEventMapBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CardEventOnMap());
}

  void showEventsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EventsHomeWidget());
}



  Future<void> addPoint(MapboxMap mapboxMap, LatLngInfo latlng,String imagePath )async{
    final unit8list = await loadMbxImage(mapboxMap, imagePath);
    final pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    
final pointAnnotation = PointAnnotationOptions(
  geometry: Point(coordinates: Position(latlng.longitude, latlng.latitude)),
  image: unit8list, // ID иконки
  iconSize: 2.5,              // Можно масштабировать иконку
);

    await pointAnnotationManager.create(pointAnnotation);
  }
  
  class LatLngInfo {
    final double latitude;
    final double longitude;

  LatLngInfo({required this.latitude, required this.longitude});
  }

  Future<Uint8List> loadMbxImage(MapboxMap mapboxMap, String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  final image = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  final mbxImage =  MbxImage(
    width: frame.image.width,
    height: frame.image.height,
    data: image!.buffer.asUint8List(),
  );
  await mapboxMap.style.addStyleImage(
  'marker-basketball',   // ID
  2.5,                   // scale
  mbxImage,          // см. ниже, как получить MbxImage
  false,
  [],
  [],
  null,
);
   return image.buffer.asUint8List();
}

