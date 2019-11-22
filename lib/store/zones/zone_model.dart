import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:google_maps_flutter/google_maps_flutter.dart';
    
class ZoneModel extends bg.Geofence {
  final LatLng location;
  final String uiId;
  final String id;

  ZoneModel(
      {String identifier = '',
      String this.id = "",
      @required double radius,
      @required double latitude,
      @required double longitude,
      @required this.uiId,
      bool notifyOnEntry = true,
      bool notifyOnExit = true,
      bool notifyOnDwell = false,
      int loiteringDelay,
      Map<String, dynamic> extras})
      : this.location = new LatLng(latitude, longitude),
        super(
          identifier: identifier,
          radius: radius,
          latitude: latitude,
          longitude: longitude,
          notifyOnEntry: notifyOnEntry,
          notifyOnExit: notifyOnExit,
          notifyOnDwell: notifyOnDwell,
          loiteringDelay: loiteringDelay,
        );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> base = super.toMap();
    base['uiId'] = this.uiId;

    return base;
  }

  @override
  String toString() => 'Zone location: $location, uiId: $uiId, id: $id, identifier: $identifier';
}