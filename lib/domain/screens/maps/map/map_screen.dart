import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/domain/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/domain/screens/maps/map/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int selectedIndex = 0;
  MapboxMap? mapboxMap;
  late geolocator.Position currentPosition;
  double currentZoom = 16;
  bool isLoading = false;
  bool showEvents = false; 

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    setState(() => isLoading = true);
    final permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied) {
      await geolocator.Geolocator.requestPermission();
    }
    final position = await geolocator.Geolocator.getCurrentPosition();
    setState(() {
      currentPosition = position;
      isLoading = false;
    });
  }

  final List<Widget> screens = [
    Placeholder(color: Colors.orangeAccent), // Events
    
    Placeholder(color: Colors.orangeAccent), // Events
    Placeholder(color: Colors.greenAccent), // Chats
    Placeholder(color: Colors.purpleAccent), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                if (selectedIndex == 0)
                  MapWidget(
                    cameraOptions: CameraOptions(
                      zoom: currentZoom,
                      center: Point(
                        coordinates: Position(
                          currentPosition.longitude,
                          currentPosition.latitude,
                        ),
                      ),
                    ),
                    key: const ValueKey("MapWidget"),
                    onMapCreated: _onMapCreated,
                  )
                else
                  screens[selectedIndex],
                Align(
                  alignment: Alignment.centerRight,
                  child: buildMapControls(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: CustomNavBar(
                      selectedIndex: selectedIndex,
                      onTabSelected: (int index) async {
                        setState(() {
                          selectedIndex = index;
                        });
                        if(selectedIndex == 0){
                         showEventsBottomSheet(context);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }





  Widget buildMapControls() {
    if (selectedIndex != 0) return SizedBox.shrink();
    return Container(
      height: 230,
      width: 59,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SvgPicture.asset('assets/left_drawer/filter.svg'),
          InkWell(
            onTap: () async {
              final camera = await mapboxMap!.getCameraState();
              await mapboxMap!.setCamera(CameraOptions(zoom: camera.zoom - 1));
            },
            child: SvgPicture.asset('assets/left_drawer/minus.svg'),
          ),
          InkWell(
            onTap: () async {
              final camera = await mapboxMap!.getCameraState();
              await mapboxMap!.setCamera(CameraOptions(zoom: camera.zoom + 1));
            },
            child: SvgPicture.asset('assets/left_drawer/plus.svg'),
          ),
          InkWell(
            onTap: () async {
              await addUserIconToStyle(mapboxMap!);
            },
            child: SvgPicture.asset('assets/left_drawer/my_location.svg'),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    await addPoint(
      mapboxMap,
      LatLngInfo(latitude: 37.33233120, longitude: -122.0302022),
      'assets/images/image_event.png',
    );
    await addUserIconToStyle(mapboxMap);
  }
}
