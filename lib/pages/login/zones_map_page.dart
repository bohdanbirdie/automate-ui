import 'dart:async';
import 'package:quiver/core.dart';
import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:automate_ui/store/zones/reducer.dart';
import 'package:automate_ui/widgets/new_location_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

final uuid = new Uuid();

class ZonesMapPage extends StatefulWidget {
  @override
  State<ZonesMapPage> createState() => ZonesMapPageState();
}

class ZonesMapPageState extends State<ZonesMapPage>
    with AutomaticKeepAliveClientMixin {
  Completer<GoogleMapController> _controller = Completer();
  String zoneName;
  bool dialogState = false;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  void _add(LatLng latlng, _MapPageViewModel viewModel) {
    _centerToLocation(latlng);
    String markerIdVal = uuid.v4();
    viewModel.onAddZone(latlng, 300, '', markerIdVal);
  }

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            child: Container(
          padding: EdgeInsets.all(10),
          height: 100,
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              Container(
                child: Text("Loading"),
                padding: EdgeInsets.all(5),
              )
            ],
          ),
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _MapPageViewModel>(
      distinct: true,
      onWillChange: (viewModel) {
        if (viewModel.zonesNetwork.loading && !dialogState) {
          _onLoading();
          setState(() {
            dialogState = true;
          });
        } else {
          if (dialogState) {
            try {
              Navigator.pop(context);
              setState(() {
                dialogState = false;
              });
            } catch (e) {}
          }
        }
      },
      converter: (store) {
        Map<String, Marker> markers = store.state.zones.zones.map((_, entry) {
          return MapEntry(
              _,
              Marker(
                markerId: MarkerId(entry.uiId),
                position: entry.location,
                icon: entry.uiId == store.state.zones.activeMarkerUiId
                    ? BitmapDescriptor.defaultMarkerWithHue(100)
                    : BitmapDescriptor.defaultMarker,
              ));
        });

        Map<String, Circle> circles = store.state.zones.zones.map((_, entry) {
          return MapEntry(
              _,
              Circle(
                circleId: CircleId(entry.uiId),
                strokeWidth: 1,
                strokeColor: Colors.blue.withOpacity(0.6),
                fillColor: Colors.blue.withOpacity(0.2),
                center: entry.location,
                radius: entry.radius,
              ));
        });

        return _MapPageViewModel(
            activeMarkerUiId: store.state.zones.activeMarkerUiId,
            markers: markers,
            circles: circles,
            saveZoneRequest: (String identifier) =>
                saveZoneRequest(store, identifier),
            onEditZone: (double radius) =>
                store.dispatch(EditActiveZone(radius: radius)),
            onCancelAddingZone: (String uiId) =>
                store.dispatch(RemoveActiveZone(uiId: uiId)),
            onAddZone: ((LatLng location, double radius, String identifier,
                    String uiId) =>
                store.dispatch(AddActiveZone(
                    identifier: identifier,
                    location: location,
                    radius: radius,
                    uiId: uiId))),
            zonesNetwork: store.state.zones.network);
      },
      builder: (context, viewModel) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _getInitialCameraPosition(viewModel),
                myLocationEnabled: true,
                myLocationButtonEnabled: viewModel.activeMarkerUiId == null,
                onLongPress: (e) => _add(e, viewModel),
                onMapCreated: (GoogleMapController controller) {
                  if (!_controller.isCompleted) {
                    _controller.complete(controller);
                  }
                },
                markers: Set<Marker>.of(viewModel.markers.values),
                circles: Set<Circle>.of(viewModel.circles.values),
              ),
            ),
            _renderSlider(viewModel)
          ],
        );
      },
    );
  }

  Widget _renderSlider(_MapPageViewModel viewModel) {
    if (viewModel.activeMarkerUiId != null) {
      return NewLocationDialog(
        radius: viewModel.circles[viewModel.activeMarkerUiId].radius,
        onChangeEnd: (newRating) {
          viewModel.onEditZone(newRating);
        },
        onSave: (saveData) {
          setState(() {
            viewModel.saveZoneRequest(saveData.zoneName);
          });
        },
        onBackgropClick: () {
          viewModel.onCancelAddingZone(viewModel.activeMarkerUiId);
        },
      );
    }
    return Container();
  }

  CameraPosition _getInitialCameraPosition(_MapPageViewModel viewModel) {
    if (viewModel.markers.length > 0) {
      Marker marker = viewModel.markers.values.first;

      CameraPosition cameraPosition = CameraPosition(
        target: marker.position,
        zoom: 14.4746,
      );

      return cameraPosition;
    }
    return _kGooglePlex;
  }

  Future<void> _centerToLocation(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  @override
  bool get wantKeepAlive => true;
}

class _MapPageViewModel {
  final Map<String, Marker> markers;
  final Map<String, Circle> circles;
  final String activeMarkerUiId;
  final NetworkState zonesNetwork;
  final Function(String uiId) onCancelAddingZone;
  final Function(String identifier) saveZoneRequest;
  final Function(double radius) onEditZone;
  final Function(
    LatLng location,
    double radius,
    String identifier,
    String uiId,
  ) onAddZone;

  _MapPageViewModel(
      {@required this.onAddZone,
      @required this.onEditZone,
      @required this.saveZoneRequest,
      @required this.onCancelAddingZone,
      @required this.zonesNetwork,
      @required this.circles,
      @required this.markers,
      @required this.activeMarkerUiId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final _MapPageViewModel typedOther = other;
    return markers.hashCode == typedOther.markers.hashCode &&
        activeMarkerUiId == typedOther.activeMarkerUiId &&
        zonesNetwork.hashCode == typedOther.zonesNetwork.hashCode;
  }

  @override
  int get hashCode => hash4(this.markers.hashCode, this.markers.hashCode,
      this.activeMarkerUiId.hashCode, this.zonesNetwork.hashCode);
}
