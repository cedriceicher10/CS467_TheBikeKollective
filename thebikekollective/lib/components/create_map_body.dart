import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'styles.dart';

class CreateMapBody extends StatefulWidget{
  CreateMapBody({Key? key}) : super(key: key);

  @override
  _CreateMapBody createState() => _CreateMapBody();
}

class _CreateMapBody extends State<CreateMapBody> {
    final PopupController _popupLayerController = PopupController();

    // Zoom functions from chunhunghan's answer here:
    // https://stackoverflow.com/questions/64034365/flutter-map-zoom-not-updating

    double currentZoom = 13.0;
    MapController mapController = MapController();
    LatLng currentCenter = LatLng(39.276, -74.576);

    void _zoom() {
      currentZoom = currentZoom - 1;
      mapController.move(currentCenter, currentZoom);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: currentCenter,
              zoom: currentZoom,
              interactiveFlags: InteractiveFlag.all,
              onTap: (a, b)
              {
                _popupLayerController.hideAllPopups();
              }
              // debug: true,
            ),
            children: <Widget>[
            TileLayerWidget(
                options:
                  TileLayerOptions(
                    overrideTilesWhenUrlChanges: false,
                    urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png?source=${DateTime.now().millisecondsSinceEpoch}",
                    subdomains: ['a', 'b', 'c'],
                    attributionBuilder: (_) {
                      return Text("© OpenStreetMap contributors");
                    },
                    additionalOptions: {},
            )),
            PopupMarkerLayerWidget(options: PopupMarkerLayerOptions(

              // Based off example_popup_with_data.dart from
              // flutter_map_marker_popup repository (the
              // plugin used here)
              // https://github.com/rorystephenson/flutter_map_marker_popup/blob/master/example/lib/example_popup_with_data.dart

              markers: <Marker>[
                  MonumentMarker(
                    monument: Monument(
                      name: 'My First Bike',
                      imagePath: 'assets/images/louis-tricot-gp1mbqUy5HI-unsplash.jpg',
                      lat: 39.278,
                      long: -74.576,
                    ),
                  ),
                  Marker(
                    anchorPos: AnchorPos.align(AnchorAlign.top),
                    point: LatLng(39.276, -74.580),
                    height: Monument.size,
                    width: Monument.size,
                    builder: (BuildContext ctx) => Icon(Icons.shop),
                  ),
                ],
                popupController: _popupLayerController,
                popupBuilder: (_, Marker marker) {
                  if (marker is MonumentMarker) {
                    return MonumentMarkerPopup(monument: marker.monument);
                  }
                  return Card(child: const Text('Not a bike'));
                },
              ),
            )
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: _zoom,
          tooltip: 'Zoom',
          backgroundColor: Color(s_jungleGreen),
          child: Icon(Icons.zoom_out_map_outlined),
        ),
      );
    }
  }

class Monument {
  static const double size = 25;

  Monument({
    required this.name,
    required this.imagePath,
    required this.lat,
    required this.long,
  });

  final String name;
  final String imagePath;
  final double lat;
  final double long;
}

class MonumentMarker extends Marker {
  MonumentMarker({required this.monument})
      : super(
    anchorPos: AnchorPos.align(AnchorAlign.top),
    height: Monument.size,
    width: Monument.size,
    point: LatLng(monument.lat, monument.long),
    builder: (BuildContext ctx) => Icon(Icons.camera_alt),
  );

  final Monument monument;
}

class MonumentMarkerPopup extends StatelessWidget {
  const MonumentMarkerPopup({Key? key, required this.monument})
      : super(key: key);
  final Monument monument;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(image: AssetImage(monument.imagePath), width: 200),
            Text(monument.name),
            Text('${monument.lat}-${monument.long}'),
          ],
        ),
      ),
    );
  }
}

double imageSizeFactor(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.portrait) {
    return 0.5;
  } else {
    return 0.15;
  }
}

double headspaceFactor(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.portrait) {
    return 60;
  } else {
    return 20;
  }
}


