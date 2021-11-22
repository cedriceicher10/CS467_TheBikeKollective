import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'dart:core';
import 'styles.dart';
import 'formatted_text.dart';
import 'home_screen_toggle.dart';
import 'package:location/location.dart';
import 'add_bike_fab.dart';
import '../utils/haversine_calculator.dart';
import 'dart:developer';

const HAVERSINE_CUTOFF_RANGE = 0.1;

const Color ActiveMarkerColor = Color(s_jungleGreen);
const Color DisabledMarkerColor = Color(s_fadedDeclineRed);

List<BikeMarker> ConvertMarkers(
    BuildContext context, List<BikeMarker> bmFuture) {
  var list = <BikeMarker>[];
  bmFuture.forEach((item) {
    list.add(item);
  });
  return list;
}

class CreateMapBody extends StatefulWidget {
  CreateMapBody({Key? key}) : super(key: key);

  @override
  _CreateMapBody createState() => _CreateMapBody();
}

class _CreateMapBody extends State<CreateMapBody>
    with TickerProviderStateMixin {
  LocationData? locationData;
  List<BikeMarker> bikes = <BikeMarker>[];
  final PopupController _popupLayerController = PopupController();
  List<BikeMarker> bikeMarkers = <BikeMarker>[];
  List<BikeMarker> markerList = <BikeMarker>[];

  var locationService = Location();
  var bikesFromDB;

  void initState() {
    super.initState();

    initLocation();
    locationService.changeSettings(interval: 1000, distanceFilter: 5);
    getBikeSnapshot();

    locationService.onLocationChanged.distinct().listen((l) async {
      retrieveLocation();
    });
  }

  void getBikeSnapshot() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('bikes').where('checkedOut', isEqualTo: false).get();

    print('DATABASE QUERIED');

    bikesFromDB = querySnapshot;
    setState(() {});
  }

  Future<List<BikeMarker>> GetBikes(BuildContext context, q) async {
    var bikes = [];
    bikeMarkers = [];

    // Convert to Bike object
    if (q != null) {
      // added: orig caused null error
      q.docs.forEach((doc) {
        Bike bike = new Bike(
            id: doc.id,
            name: doc['Name'],
            imagePath: doc['imageURL'],
            lat: doc['Latitude'],
            long: doc['Longitude'],
            description: doc['Description'],
            condition: doc['Condition']);
        bikes.add(bike);
        //var lat = locationData!.latitude; // orig: caused null error
        //var long = locationData!.longitude; // orig: caused null error

        final lat = locationData?.latitude ?? 0.0;
        final long = locationData?.longitude ?? 0.0;

        if (haversineCalculator(lat, long, doc['Latitude'], doc['Longitude']) <
            HAVERSINE_CUTOFF_RANGE) {
          bikeMarkers.add(
              new BikeMarker(bike: bike, markerColor: ActiveMarkerColor));
        } else {
          bikeMarkers.add(
              new BikeMarker(bike: bike, markerColor: DisabledMarkerColor));
        }
      });
    }

    return bikeMarkers;
  }

  void retrieveLocation() async {
    var oldLocationData = locationData;
    locationData = await locationService.getLocation();

    if ((locationData!.latitude! - oldLocationData!.latitude!).abs() > 0.0001) {
      print(locationData!.longitude);
      print(locationData!.latitude);
      setState(() {});
    }
  }

  void initLocation() async {
    locationData = await locationService.getLocation();

    print(locationData!.longitude);
    print(locationData!.latitude);

    setState(() {});
  }

  // Zoom functions from chunhunghan's answer here:
  // https://stackoverflow.com/questions/64034365/flutter-map-zoom-not-updating

  double currentZoom = 15;
  MapController? mapController = new MapController();
  LatLng currentCenter = LatLng(39.276, -74.576);

  void _zoom() {
    currentZoom = currentZoom - 1;
    mapController!.move(currentCenter, currentZoom);
  }

  // This is pretty much entirely from the flutter_map's
  // `animated_map_controller.dart` example in their repository.
  // it can be viewed here:
  // https://github.com/rorystephenson/flutter_map/blob/master/example/lib/pages/animated_map_controller.dart

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController!.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController!.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController!.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController!.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    currentZoom = destZoom;
    currentCenter = destLocation;

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    //final userLat = locationData?.latitude; // orig: caused null error
    //final userLong = locationData?.longitude; // orig: caused null error

    final userLat = locationData?.latitude ?? 0.0;
    final userLong = locationData?.longitude ?? 0.0;

    return FutureBuilder<List<BikeMarker>>(
        future: GetBikes(context, bikesFromDB),
        builder: (context, snapshot) {
          List<BikeMarker>? returnData;
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              markerList = [];
              returnData = snapshot.data;
              returnData!.forEach((el) {
                markerList.add(el);
              });
            }

            return Scaffold(
              body: FlutterMap(
                  mapController: new MapController(),
                  options: MapOptions(
                      onMapCreated: (c) {
                        mapController = c;
                      },
                      center: LatLng(userLat, userLong),
                      zoom: currentZoom,
                      // Conzar! You can disable rotation using this,
                      // but try not to take the easy way out:
                      interactiveFlags: InteractiveFlag.all,
                      onTap: (a, b) {
                        _popupLayerController.hideAllPopups();
                      }
                      // debug: true,
                      ),
                  children: <Widget>[
                    TileLayerWidget(
                        options: TileLayerOptions(
                      overrideTilesWhenUrlChanges: false,
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png?source=${DateTime.now().millisecondsSinceEpoch}",
                      subdomains: ['a', 'b', 'c'],
                      attributionBuilder: (_) {
                        return Text("© OpenStreetMap contributors");
                      },
                      additionalOptions: {},
                    )),
                    LocationMarkerLayerWidget(),
                    PopupMarkerLayerWidget(
                      options: PopupMarkerLayerOptions(

                          // Based off example_popup_with_data.dart from
                          // flutter_map_marker_popup repository (the
                          // plugin used here)
                          // https://github.com/rorystephenson/flutter_map_marker_popup/blob/master/example/lib/example_popup_with_data.dart
                          markers: markerList,
                          popupSnap: PopupSnap.mapTop,
                          popupAnimation: PopupAnimation.fade(
                              duration: Duration(milliseconds: 300)),
                          popupController: _popupLayerController,
                          popupBuilder: (_, Marker marker) {
                            if (marker is BikeMarker &&
                                haversineCalculator(
                                        userLat,
                                        userLong,
                                        marker.point.latitude,
                                        marker.point.longitude) <
                                    HAVERSINE_CUTOFF_RANGE) {
                              return BikeMarkerPopup(
                                  bike: marker.bike, inRange: true);
                            } else if (marker is BikeMarker) {
                              return BikeMarkerPopup(
                                  bike: marker.bike, inRange: false);
                            }
                            return Card(child: const Text('Not a bike'));
                          },
                          markerTapBehavior: MarkerTapBehavior.custom(
                              (marker, popupController) => {
                                    popupController.hideAllPopups(),
                                    popupController.togglePopup(marker),
                                    _animatedMapMove(marker.point, 17)
                                  })),
                    )
                  ]),
              floatingActionButton:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                AddBikeFAB(),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "Zoom FAB",
                  onPressed: _zoom,
                  tooltip: 'Zoom',
                  backgroundColor: Color(s_jungleGreen),
                  child: Icon(Icons.zoom_out_map_outlined),
                ),
                SizedBox(height: 10),
                HomeScreenToggle(map: false)
              ]),
            );
          }
          return Center();
        });
  }
}

class Bike {
  static const double size = 25;

  Bike(
      {required this.id,
      required this.name,
      required this.imagePath,
      required this.lat,
      required this.long,
      required this.description,
      required this.condition});

  final String id;
  final String name;
  final String imagePath;
  final double lat;
  final double long;
  final String description;
  final String condition;
}

class BikeMarker extends Marker {
  BikeMarker({required this.bike, required this.markerColor})
      : super(
            anchorPos: AnchorPos.align(AnchorAlign.top),
            height: Bike.size,
            width: Bike.size,
            point: LatLng(bike.lat, bike.long),
            builder: (BuildContext ctx) => new Container(
                  child: new Icon(Icons.location_pin,
                      color: markerColor, size: 30.0),
                ));

  void setMarkerColor(color) {
    this.markerColor = color;
  }

  Color getMarkerColor() {
    return this.markerColor;
  }

  final Bike bike;
  var markerColor;
}

class DisabledBikeMarker extends Marker {
  DisabledBikeMarker({required this.bike})
      : super(
            anchorPos: AnchorPos.align(AnchorAlign.top),
            height: Bike.size,
            width: Bike.size,
            point: LatLng(bike.lat, bike.long),
            builder: (BuildContext ctx) => new Container(
                  child: new Icon(Icons.location_pin,
                      color: DisabledMarkerColor, size: 30.0),
                ));

  final Bike bike;
}

class BikeMarkerPopup extends StatelessWidget {
  const BikeMarkerPopup({Key? key, required this.bike, required this.inRange})
      : super(key: key);
  final Bike bike;
  final bool inRange;

  @override
  Widget build(BuildContext context) {
    if (!isLandscape(context)) {
      return portraitLayout(context, bike, inRange);
    } else {
      return landscapeLayout(context, bike, inRange);
    }
  }
}

Container portraitLayout(BuildContext context, bike, inRange) {
  return Container(
    width: double.infinity,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(children: <Widget>[
                      Image(
                          image: NetworkImage(bike.imagePath),
                          width: 150 * imageSizeFactor(context),
                          height: 150 * imageSizeFactor(context)),
                    ]),
                    Column(children: <Widget>[
                      Text(bike.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end),
                      SizedBox(height: 8),
                      Text('${bike.description}'),
                      SizedBox(height: 8),
                      Text('Condition: ${bike.condition}'),
                      SizedBox(height: 8),
                      rideButton(context, inRange, 100, 25, bike.id)
                    ])
                  ]))
        ],
      ),
    ),
  );
}

Container landscapeLayout(BuildContext context, bike, inRange) {
  return Container(
    alignment: Alignment.topLeft,
    height: double.infinity,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Image(
                        image: NetworkImage(bike.imagePath),
                        width: 150 * imageSizeFactor(context),
                        height: 150 * imageSizeFactor(context)),
                    Column(children: <Widget>[
                      Text(bike.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end),
                      SizedBox(height: 8),
                      Text('${bike.description}'),
                      SizedBox(height: 8),
                      Text('Condition: ${bike.condition}'),
                      SizedBox(height: 8),
                      rideButton(context, inRange, 100, 25, bike.id)
                    ])
                  ]))
        ],
      ),
    ),
  );
}

//This will become the Start Ride button
Widget rideButton(BuildContext context, bool inRange, double buttonWidth,
    double buttonHeight, String id) {
  var text = '';
  var color;

  if (inRange) {
    text = 'Ride Me!';
    color = Color(s_jungleGreen);
  } else {
    text = 'Too Far';
    color = Color(s_disabledGray);
  }
  return ElevatedButton(
      onPressed: () {
        if (inRange) {
          Navigator.of(context).pushNamedAndRemoveUntil('rideScreen', (_) => false, arguments: id);
        }
        return;
      },
      child: rideButtonText(text),
      style: ElevatedButton.styleFrom(
          primary: color, fixedSize: Size(buttonWidth, buttonHeight)));
}

/*
Widget rideButton(BuildContext context, String text,
    double buttonWidth, double buttonHeight) {
  return ElevatedButton(
      onPressed: () {
        return;
      },
      child: rideButtonText(text),
      style: ElevatedButton.styleFrom(
          primary: Color(s_jungleGreen),
          fixedSize: Size(buttonWidth, buttonHeight)));
}
*/

Widget rideButtonText(String text) {
  return FormattedText(
    text: text,
    size: s_fontSizeSmall,
    color: Colors.white,
    weight: FontWeight.bold,
  );
}

double imageSizeFactor(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.portrait) {
    return 1;
  } else {
    return 1;
  }
}

bool isLandscape(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    return true;
  } else {
    return false;
  }
}

double headspaceFactor(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.portrait) {
    return 60;
  } else {
    return 20;
  }
}
