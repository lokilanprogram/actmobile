import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/data/models/local_address_model.dart';
import 'package:acti_mobile/data/models/mapbox_reverse_model.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/presentation/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPickerScreen extends StatefulWidget {
  final Position? position;
  final bool? isCreated;
  final String? address;
  const MapPickerScreen(
      {super.key,
      required this.position,
      required this.address,
      required this.isCreated});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final searchController = TextEditingController();
  MapboxMap? mapboxMap;
  bool isLoading = false;
  Properties? tappedProperties;
  geolocator.Position? currentPosition;
  Position? tappedPosition;
  late PointAnnotationManager pointAnnotationManager;
  double currentZoom = 15.5;
  bool isFullSheet = false;

  List<MapBoxSuggestion> _suggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  void initialize() async {
    setState(() => isLoading = true);
    if (widget.position == null && widget.address == null) {
      final permission = await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        await geolocator.Geolocator.requestPermission();
      }

      final position = await geolocator.Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = position;
        isLoading = false;
      });
    } else {
      setState(() {
        tappedPosition = widget.position;
        isLoading = false;
      });
    }
  }

  initializeAddress(double lng, double lat) async {
    final result = await loadMbxImage(
        mapboxMap!, 'assets/icons/pointer_icon.png', 'pointer_icon');
    final pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(coordinates: Position(lng, lat)),
      iconSize: 1.8,
      image: result,
      iconImage: "pointer_icon",
    );

    await pointAnnotationManager.create(pointAnnotationOptions);
    final address =
        await EventsApi().getMapBoxAddress(lng.toString(), lat.toString());
    setState(() {
      tappedProperties = address.features.first.properties;
      tappedPosition = Position(lng, lat);
    });
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    setState(() {
      this.mapboxMap = mapboxMap;
    });
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await mapboxMap.gestures.updateSettings(
      GesturesSettings(
        pinchToZoomEnabled: true,
        doubleTapToZoomInEnabled: true,
        doubleTouchToZoomOutEnabled: true,
        scrollEnabled: true,
        rotateEnabled: true,
        pitchEnabled: true,
      ),
    );
    final annotationPlugin = mapboxMap.annotations;
    final pointNewAnnotationManager =
        await annotationPlugin.createPointAnnotationManager();
    setState(() {
      pointAnnotationManager = pointNewAnnotationManager;
    });
    if (widget.position == null) {
      await initializeAddress(
          currentPosition!.longitude, currentPosition!.latitude);
    } else {
      await initializeAddress(
          widget.position!.lng.toDouble(), widget.position!.lat.toDouble());
    }
  }

  _onTap(MapContentGestureContext context) async {
    await pointAnnotationManager.deleteAll();
    final result = await loadMbxImage(
        mapboxMap!, 'assets/icons/pointer_icon.png', 'pointer_icon');
    final pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(
          coordinates: Position(
              context.point.coordinates.lng, context.point.coordinates.lat)),
      iconSize: 1.8,
      image: result,
      iconImage: "pointer_icon",
    );

    await pointAnnotationManager.create(pointAnnotationOptions);
    final address = await EventsApi().getMapBoxAddress(
        context.point.coordinates.lng.toString(),
        context.point.coordinates.lat.toString());
    setState(() {
      tappedProperties = address.features.first.properties;
      tappedPosition = Position(
          context.point.coordinates.lng, context.point.coordinates.lat);
    });
    print(
        "OnTap coordinate: {${context.point.coordinates.lng}, ${context.point.coordinates.lat}}"
        " point: {x: ${context.touchPosition.x}, y: ${context.touchPosition.y}}");
  }

  Future<void> _searchLocation(String place) async {
    if (place.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      // Получаем текущие координаты для сортировки по удаленности
      final currentLng =
          widget.position?.lng ?? currentPosition?.longitude ?? 37.6173;
      final currentLat =
          widget.position?.lat ?? currentPosition?.latitude ?? 55.7558;

      final encodedPlace = Uri.encodeComponent(place);
      final url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedPlace.json'
          '?language=ru'
          '&country=ru'
          '&types=place,address,locality,neighborhood'
          '&proximity=$currentLng,$currentLat'
          '&access_token=pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg';

      print('Search URL: $url'); // Отладочный вывод URL

      final response = await http.get(Uri.parse(url));
      print(
          'Response status: ${response.statusCode}'); // Отладочный вывод статуса
      print('Response body: ${response.body}'); // Отладочный вывод тела ответа

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List features = data['features'] ?? [];
        print(
            'Found features: ${features.length}'); // Отладочный вывод количества найденных мест

        setState(() {
          _suggestions =
              features.map((f) => MapBoxSuggestion.fromJson(f)).toList();
        });
      } else {
        print('Error response: ${response.body}'); // Отладочный вывод ошибки
        setState(() => _suggestions = []);
      }
    } catch (e) {
      print('Exception during search: $e'); // Отладочный вывод исключения
      setState(() => _suggestions = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _onSuggestionTap(MapBoxSuggestion suggestion) async {
    setState(() {
      print('Suggestion text: \\${suggestion.text}');
      print('Suggestion placeName: \\${suggestion.placeName}');
      searchController.text = suggestion.shortAddress;
      _suggestions = [];
    });
    await pointAnnotationManager.deleteAll();
    final result = await loadMbxImage(
        mapboxMap!, 'assets/icons/pointer_icon.png', 'pointer_icon');
    final pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(
          coordinates: Position(suggestion.longitude, suggestion.latitude)),
      iconSize: 1.8,
      image: result,
      iconImage: "pointer_icon",
    );
    await pointAnnotationManager.create(pointAnnotationOptions);
    mapboxMap?.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(suggestion.longitude, suggestion.latitude),
        ),
        zoom: currentZoom,
      ),
      MapAnimationOptions(duration: 1000),
    );
    setState(() {
      tappedPosition = Position(suggestion.longitude, suggestion.latitude);
      tappedProperties = Properties(
        name: suggestion.shortAddress,
        fullAddress: suggestion.placeName,
        mapboxId: '',
        featureType: '',
        namePreferred: '',
        coordinates: Coordinates(
          longitude: suggestion.longitude,
          latitude: suggestion.latitude,
        ),
        context: Context(
          country: Country(
            mapboxId: 'RU',
            name: 'Россия',
            wikidataId: 'Q159',
            countryCode: 'RU',
            countryCodeAlpha3: 'RUS',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MapWidget(
                  onTapListener: _onTap,
                  styleUri: 'mapbox://styles/acti/cmbf00t92005701s5d84c1cqp',
                  cameraOptions: CameraOptions(
                    zoom: currentZoom,
                    center: Point(
                      coordinates: widget.position ??
                          Position(
                            currentPosition?.longitude ?? 37.6173,
                            currentPosition?.latitude ?? 55.7558,
                          ),
                    ),
                  ),
                  key: const ValueKey("MapWidget"),
                  onMapCreated: _onMapCreated,
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          controller: searchController,
                          onChanged: _searchLocation,
                          decoration: InputDecoration(
                            hintText: 'Поиск по адресу',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  _suggestions = [];
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      if (_suggestions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _suggestions.length,
                            separatorBuilder: (context, idx) =>
                                Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final s = _suggestions[idx];
                              return ListTile(
                                title: Text(s.text,
                                    style: TextStyle(fontSize: 16)),
                                subtitle: Text(s.placeName,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey)),
                                onTap: () => _onSuggestionTap(s),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: !isFullSheet
                        ? null
                        : MediaQuery.of(context).size.height * 0.85,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(102, 102, 102, 1),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                        const Text(
                          'Место',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        !isFullSheet
                            ? buildSavedLocation(context)
                            : buildSuggestedLocation()
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Column buildSuggestedLocation() {
    return Column(
      children: [
        TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Поиск',
            isDense: true,
            suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset('assets/icons/icon_vert_divider.svg'),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Карта ',
                    style: TextStyle(fontFamily: 'Gilroy', fontSize: 16),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 1.2, color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 1.2, color: Colors.grey),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Column(
          children: [
            ListTile(
              onTap: () {
                setState(() {
                  isFullSheet = !isFullSheet;
                });
              },
              leading: SvgPicture.asset('assets/icons/icon_dot.svg'),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      tappedProperties?.name ?? '...',
                      style: TextStyle(fontFamily: 'Gilroy', fontSize: 24),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  )
                ],
              ),
              subtitle: null,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Divider(),
            ),
          ],
        ),
      ],
    );
  }

  Column buildSavedLocation(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Divider(),
        ),
        ListTile(
          // onTap: () {
          //   setState(() {
          //     isFullSheet = !isFullSheet;
          //   });
          // },
          leading: SvgPicture.asset('assets/icons/icon_dot.svg'),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  tappedProperties?.name ?? '...',
                  style: TextStyle(fontFamily: 'Gilroy', fontSize: 24),
                ),
              ),
              // Icon(
              //   Icons.arrow_forward_ios,
              //   size: 12,
              // )
            ],
          ),
          subtitle: null,
        ),
        InkWell(
          onTap: () {
            Navigator.pop(
                context,
                LocalAddressModel(
                    address: tappedProperties?.name,
                    latitude: tappedPosition?.lat.toDouble(),
                    longitude: tappedPosition?.lng.toDouble(),
                    properties: tappedProperties));
          },
          child: Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
            child: Container(
              height: 59,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  color: mainBlueColor),
              child: Center(
                  child: Text(
                widget.isCreated == false ? 'Закрыть' : 'Сохранить',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Gilroy',
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              )),
            ),
          ),
        ),
      ],
    );
  }
}

// Вспомогательная модель для подсказок Mapbox
class MapBoxSuggestion {
  final String text;
  final String placeName;
  final double latitude;
  final double longitude;
  final String? city;
  final String? streetAndHouse;

  MapBoxSuggestion({
    required this.text,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    this.city,
    this.streetAndHouse,
  });

  factory MapBoxSuggestion.fromJson(Map<String, dynamic> json) {
    String? city;
    String? streetAndHouse;

    // 1. Если тип feature — address, то text = "улица", а дом — из place_name
    if (json['place_type'] != null &&
        (json['place_type'] as List).contains('address')) {
      final street = json['text'] ?? '';
      final placeName = json['place_name'] ?? '';
      String? house;
      if (placeName.contains(street)) {
        final idx = placeName.lastIndexOf(street);
        if (idx != -1) {
          final after = placeName.substring(idx + street.length).trim();
          // after = "32" или "32 корпус 1"
          // Берём только первые 10 символов после улицы (на случай длинных адресов)
          final houseMatch = RegExp(r'^(\d+.*?)(,|$)').firstMatch(after);
          if (houseMatch != null) {
            house = houseMatch.group(1)?.trim();
          } else if (after.isNotEmpty) {
            house = after.split(',').first.trim();
          }
        }
      }
      streetAndHouse =
          house != null && house.isNotEmpty ? '$street $house' : street;
    }

    // 2. Парсим context для города
    if (json['context'] != null) {
      for (final ctx in json['context']) {
        if (ctx['id'] != null &&
            (ctx['id'].toString().startsWith('place') ||
                ctx['id'].toString().startsWith('locality'))) {
          city = ctx['text'];
        }
      }
    }

    // 3. Если streetAndHouse пусто, fallback на text
    if (streetAndHouse == null || streetAndHouse.isEmpty) {
      streetAndHouse = json['text'] ?? '';
    }

    return MapBoxSuggestion(
      text: json['text'] ?? '',
      placeName: json['place_name'] ?? '',
      latitude: (json['center'] as List).last.toDouble(),
      longitude: (json['center'] as List).first.toDouble(),
      city: city,
      streetAndHouse: streetAndHouse,
    );
  }

  String get shortAddress {
    if (city != null && streetAndHouse != null && streetAndHouse!.isNotEmpty) {
      return '$city, $streetAndHouse';
    }
    if (city != null) {
      return city!;
    }
    return placeName;
  }
}

String getShortAddress(String placeName) {
  // Обычно placeName: "улица, дом, корпус, город, регион, страна"
  final parts = placeName.split(', ');
  if (parts.length >= 3) {
    return parts.take(3).join(', ');
  }
  return placeName;
}
