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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Stack(
                children: [
                  MapWidget(
                    onTapListener: widget.isCreated == true ? _onTap : null,
                    styleUri: 'mapbox://styles/acti/cmbf00t92005701s5d84c1cqp',
                    cameraOptions: CameraOptions(
                      zoom: currentZoom,
                      center: Point(
                        coordinates: widget.position == null
                            ? Position(
                                currentPosition!.longitude,
                                currentPosition!.latitude,
                              )
                            : widget.position!,
                      ),
                    ),
                    key: const ValueKey("MapWidget"),
                    onMapCreated: _onMapCreated,
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
              subtitle: Text(
                tappedProperties?.fullAddress.split(', ')[2] ?? '...',
                style: TextStyle(
                    fontFamily: 'Gilroy', fontSize: 15, color: Colors.grey),
              ),
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
          subtitle: Text(
            tappedProperties?.fullAddress.split(', ')[2] ?? '...',
            style: TextStyle(
                fontFamily: 'Gilroy', fontSize: 15, color: Colors.grey),
          ),
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
