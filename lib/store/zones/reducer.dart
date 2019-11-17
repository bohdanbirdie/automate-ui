import 'dart:convert';

import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redux/redux.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

final AuthService authService = new AuthService();

class Zone extends bg.Geofence {
  final LatLng location;
  final String uiId;

  Zone(
      {String identifier = '',
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
}

class ZonesState {
  final Map<String, Zone> zones;
  final String activeMarkerUiId;
  final NetworkState network;

  const ZonesState(
      {this.zones = const {},
      this.network = const NetworkState(),
      this.activeMarkerUiId});

  ZonesState clone(
      {Map<String, Zone> zones,
      NetworkState network,
      String activeMarkerUiId}) {
    return new ZonesState(
        zones: zones ?? this.zones,
        network: network ?? this.network,
        activeMarkerUiId: activeMarkerUiId);
  }
}

class SaveZoneRequest {}

class SaveZoneSuccess {}

class SaveZoneFailure {}


class GetZonesRequest {}

class GetZonesSuccess {
  final Map<String, Zone> zones;

  GetZonesSuccess._(this.zones);

  factory GetZonesSuccess(String zonesResponse) {
    Iterable zonesPayload = jsonDecode(zonesResponse);
    Iterable<Zone> zones = zonesPayload.map((zone) {
      try {
        return new Zone(
          identifier: zone['identifier'],
          latitude: double.parse(zone['latitude']),
          longitude: double.parse(zone['longitude']),
          radius: double.parse(zone['radius']),
          uiId: zone['uiId'],
        );
      } catch (e) {
        return null;
      }
    }).where((zone) => zone != null);

    return GetZonesSuccess._(Map.fromIterable(zones,
        key: (zone) => zone.uiId, value: (zone) => zone));
  }
}

class GetZonesFailure {}

class AddActiveZone {
  final LatLng location;
  final String identifier;
  final String uiId;
  final double radius;

  AddActiveZone({
    @required this.location,
    @required this.identifier,
    @required this.uiId,
    @required this.radius,
  });
}

class EditActiveZone {
  final double radius;

  EditActiveZone({
    @required this.radius,
  });
}

class RemoveActiveZone {
  final String uiId;

  RemoveActiveZone({
    @required this.uiId,
  });
}

void saveZoneRequest(Store<AppState> store, String identifier) async {
  String activeMarkerUiId = store.state.zones.activeMarkerUiId;
  Zone activeZone = store.state.zones.zones[activeMarkerUiId];
  store.dispatch(SaveZoneRequest());
  activeZone.identifier = identifier;

  try {
    Response response = await httpService.post('/users/zone', data: activeZone.toMap());

    if (response.statusCode != 201) {
      throw new Exception('Failed to save');
    }

    store.dispatch(SaveZoneSuccess());
  } on Exception catch (e) {
    store.dispatch(SaveZoneFailure());
  }
}

void getZonesRequest(Store<AppState> store) async {
  store.dispatch(GetZonesRequest());

  try {
    Response<String> response = await httpService.get('/zones');

    if (response.statusCode != 200) {
      throw new Exception('Failed to load zones');
    }

    store.dispatch(GetZonesSuccess(response.data)); // TODO: this should not be string, add decoder to model
  } on Exception catch (e) {
    store.dispatch(GetZonesFailure());
  }
}

ZonesState zonesReducer(ZonesState state, action) {
  switch (action.runtimeType) {
    case GetZonesRequest:
      return state.clone(
        network: NetworkState.request()
      );

    case GetZonesSuccess:
      return state.clone(
        network: NetworkState.success(),
        zones: action.zones,
      );

    case GetZonesFailure:
      return state.clone(
        network: NetworkState.failure(errorMessage: '')
      );

    case SaveZoneRequest:
      return state.clone(
          network: NetworkState.request(),
          activeMarkerUiId: state.activeMarkerUiId);

    case SaveZoneSuccess:
      return state.clone(
        network: NetworkState.success(),
      );

    case SaveZoneFailure:
      return state.clone(
          network: NetworkState.failure(errorMessage: ''),
          activeMarkerUiId: state.activeMarkerUiId);

    case AddActiveZone:
      Map<String, Zone> newZones = Map<String, Zone>.from(state.zones);
      newZones[action.uiId] = new Zone(
        identifier: action.identifier,
        latitude: action.location.latitude,
        longitude: action.location.longitude,
        radius: action.radius,
        uiId: action.uiId,
      );

      return state.clone(
          zones: newZones,
          activeMarkerUiId: action.uiId); // TODO: check if this even make sense
    case RemoveActiveZone:
      Map<String, Zone> newZones = Map<String, Zone>.from(state.zones);
      newZones.remove(action.uiId);

      return state.clone(zones: newZones, activeMarkerUiId: null);

    case EditActiveZone:
      Map<String, Zone> newZones = Map<String, Zone>.from(state.zones);
      Zone target = newZones[state.activeMarkerUiId];
      target.radius = action.radius;
      return state.clone(
          zones: newZones, activeMarkerUiId: state.activeMarkerUiId);
  }

  return state;
}
