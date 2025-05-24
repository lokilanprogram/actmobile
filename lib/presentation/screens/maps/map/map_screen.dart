import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/marker.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/data/models/searched_events_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_main/chat_main_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/screens/maps/event/widgets/events_home_map_widget.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/get/my_events_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/profile_menu/profile_menu_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  WidgetsToImageController controller = WidgetsToImageController();
  int selectedIndex = 0;
  MapboxMap? mapboxMap;
  late geolocator.Position currentPosition;
  double currentZoom = 16;
  bool isLoading = false;
  bool showEvents = false;
  DraggableScrollableController sheetController =
      DraggableScrollableController();
  SearchedEventsModel? searchedEventsModel;    

  late PointAnnotationManager pointAnnotationManager;
  final String eventsSourceId = "events-source";
final String eventsLayerId = "events-layer";
final String iconImageIdPrefix = "event-icon-";

  @override
  void initState() {
    super.initState();
    initialize();
    sheetController.addListener(() async {
      if (sheetController.size <= 0.5) {
        setState(() {
          showEvents = false;
        });
      }
    });
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
    });
    
    context.read<ProfileBloc>().add(SearchEventsOnMapEvent(latitude: currentPosition.latitude, longitude: currentPosition.longitude));
  }

  final List<Widget> screens = [
    Placeholder(color: Colors.orangeAccent), // Events
    Placeholder(color: Colors.orangeAccent), // Events
    ChatMainScreen(), // Chats
    ProfileMenuScreen() // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if(state is SearchedEventsOnMapState){
          setState(() {
            searchedEventsModel = state.searchedEventsModel;
            isLoading = false;
          });
         
        }
        if(state is ProfileUpdatedState){
          initialize();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? const LoaderWidget()
            : Stack(
                children: [
                  if (selectedIndex == 0)
                    MapWidget(
                      styleUri:
                          'mapbox://styles/acti/cma9wrmfh00i701sdhqrjg5mj',
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
                  WidgetsToImage(
              controller: controller,
              child: InkWell(
                child: CustomMarkerWidget(text: 'Баскетбол',iconUrl: 'http://93.183.81.104/uploads/profile_photos/f07cb015-296d-467c-974c-add75c5d909c.jpg',)),
            ),
                  if (showEvents)
                    DraggableScrollableSheet(
                      controller: sheetController,
                      initialChildSize: 0.8, // стартовая высота
                      builder: (context, scrollController) {
                        return EventsHomeListOnMapWidget(
                            scrollController: scrollController);
                      },
                    ),
                  selectedIndex == 3
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 140),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MyEventsScreen()));
                              },
                              child: Material(
                                elevation: 1.2,
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  height: 59,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  decoration: BoxDecoration(
                                    color: mainBlueColor,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                          'assets/icons/icon_event_bar.svg'),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Мои события',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Gilroy',
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: CustomNavBarWidget(
                        selectedIndex: selectedIndex,
                        onTabSelected: (int index) async {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildMapControls() {
    if (selectedIndex != 0) return SizedBox.shrink();
    return Container(
      width: 59,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20,bottom: 20),
        child: Column(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: SvgPicture.asset('assets/left_drawer/filter.svg'),
            onPressed: (){},),
            IconButton(
              onPressed: () async {
                final camera = await mapboxMap!.getCameraState();
                await mapboxMap!.setCamera(CameraOptions(zoom: camera.zoom - 1));
              },
              icon: SvgPicture.asset('assets/left_drawer/minus.svg'),
            ),
            IconButton(
              onPressed: () async {
                final camera = await mapboxMap!.getCameraState();
                await mapboxMap!.setCamera(CameraOptions(zoom: camera.zoom + 1));
              },
              icon: SvgPicture.asset('assets/left_drawer/plus.svg'),
            ),
            IconButton(
              onPressed: () async {
                await mapboxMap!.setCamera(CameraOptions(
                    center: Point(
                        coordinates: Position(
                            currentPosition.longitude, currentPosition.latitude)),
                    zoom: currentZoom));
              },
              icon: SvgPicture.asset('assets/left_drawer/my_location.svg'),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    setState(() {
      this.mapboxMap = mapboxMap;
    });
    final pointNewAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    setState(() {
      pointAnnotationManager= pointNewAnnotationManager;
    });
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await mapboxMap
        .loadStyleURI('mapbox://styles/acti/cma9wrmfh00i701sdhqrjg5mj');
    
     for(var event in searchedEventsModel!.events){
           final bytes = await controller.capture();
           await addEventIconFromUrl(mapboxMap, 'pointer:${event.id}', bytes!);
            final pointAnnotationOptions = PointAnnotationOptions(
    geometry: Point(coordinates: Position(event.longitude!, event.latitude!)),
    iconSize: 0.5,
    image: bytes,
    iconImage: 'pointer:${event.id}', 
  );
  await pointAnnotationManager.create(pointAnnotationOptions);
          }
    await addUserIconToStyle(mapboxMap);
  }
}


Future<Uint8List> createCustomMarkerWidgetAsBytes(String text, String iconUrl) async {
  final completer = Completer<Uint8List>();
  final repaintBoundary = GlobalKey();

  final widget = RepaintBoundary(
    key: repaintBoundary,
    child: Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(iconUrl, width: 20, height: 20),
            const SizedBox(width: 5),
            Text(text, style: TextStyle(fontSize: 14, color: Colors.blue)),
          ],
        ),
      ),
    ),
  );

  final RenderRepaintBoundary boundary =
      repaintBoundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  completer.complete(byteData!.buffer.asUint8List());

  return completer.future;
}
