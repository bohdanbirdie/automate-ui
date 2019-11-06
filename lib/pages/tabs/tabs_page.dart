import 'dart:async';

import 'package:automate_ui/helpers/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

final uuid = new Uuid();

class TabsPage extends StatefulWidget {
  @override
  State<TabsPage> createState() => TabsPageState();
}

class TabsPageState extends State<TabsPage> {
  Completer<GoogleMapController> _controller = Completer();
  Map<String, Marker> markers = <String, Marker>{};
  Map<String, Circle> circles = <String, Circle>{};
  String activeMarker;
  double activeMarkerInstantValue;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  void _add(LatLng latlng) {
    String markerIdVal = uuid.v4();
    final MarkerId markerId = MarkerId(markerIdVal);
    final CircleId circleId = CircleId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: latlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(100),
      onTap: () {
        setState(() {
          activeMarker = markerIdVal;
          activeMarkerInstantValue = circles[markerIdVal].radius;
          markers[activeMarker] = markers[activeMarker].copyWith(iconParam: BitmapDescriptor.defaultMarkerWithHue(100));
        });
      },
    );

    final Circle circle = Circle(
      circleId: circleId,
      strokeWidth: 1,
      strokeColor: Colors.blue.withOpacity(0.6),
      fillColor: Colors.blue.withOpacity(0.2),
      center: latlng,
      radius: 300,
    );

    setState(() {
      // adding a new marker to map
      circles[markerIdVal] = circle;
      markers[markerIdVal] = marker;
      activeMarker = markerIdVal;
      activeMarkerInstantValue = circle.radius;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Tabs"),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            onLongPress: _add,
            onTap: (_) {
              setState(() {
                markers[activeMarker] = markers[activeMarker].copyWith(iconParam: BitmapDescriptor.defaultMarker);
                activeMarker = null;
                activeMarkerInstantValue = null;
              });
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: Set<Marker>.of(markers.values),
            circles: Set<Circle>.of(circles.values),
          ),
          _renderSlider()
        ],
      ),
    );
  }

  Widget _renderSlider() {
    if (activeMarker != null) {
      return Container(
        margin: EdgeInsets.only(bottom: 40),
        decoration: new BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: Offset(5.0, 5.0),
            )
          ],
          borderRadius: new BorderRadius.circular(15.0),
        ),
        width: MediaQuery.of(context).size.width * 0.80,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Slider(
              activeColor: Colors.indigoAccent,
              label: circles[activeMarker].radius.toString(),
              min: 0,
              max: 1.0,
              onChangeEnd: (newRating) {
                setState(() => circles[activeMarker] = circles[activeMarker]
                    .copyWith(radiusParam: newRating * 1000));
              },
              onChanged: (newRating) {
                setState(() => activeMarkerInstantValue = newRating * 1000);
              },
              value: activeMarkerInstantValue / 1000,
            ),
            Padding(
              child: Text(
                activeMarkerInstantValue.toInt().toString(),
                style: TextStyle(
                  color: Colors.indigoAccent,
                ),
              ),
              padding: EdgeInsets.only(right: 10),
            ),
            SizedBox(
                width: 65,
                child: ClipRRect(
                    borderRadius: new BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                    child: RaisedButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        setState(() {
                          circles.remove(activeMarker);
                          markers.remove(activeMarker);
                          activeMarker = null;
                          activeMarkerInstantValue = null;
                        });
                      },
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration:
                            new BoxDecoration(color: Colors.indigoAccent),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                    ))),
          ],
        ),
      );
    }
    return Container();
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
