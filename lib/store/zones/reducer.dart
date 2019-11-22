import 'dart:convert';

import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:automate_ui/store/zones/zone_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redux/redux.dart';


final AuthService authService = new AuthService();

class ZonesState {
  final Map<String, ZoneModel> zones;
  final String activeMarkerUiId;
  final NetworkState network;

  const ZonesState(
      {this.zones = const {},
      this.network = const NetworkState(),
      this.activeMarkerUiId});

  ZonesState clone(
      {Map<String, ZoneModel> zones,
      NetworkState network,
      String activeMarkerUiId}) {
    return new ZonesState(
        zones: zones ?? this.zones,
        network: network ?? this.network,
        activeMarkerUiId: activeMarkerUiId);
  }
}

class SaveZoneRequest {}

class SaveZoneSuccess {
  final ZoneModel zone;

  SaveZoneSuccess({
    @required this.zone,
  });
}

class SaveZoneFailure {}


class GetZonesRequest {}

class GetZonesSuccess {
  final Map<String, ZoneModel> zones;

  GetZonesSuccess._(this.zones);

  factory GetZonesSuccess(String zonesResponse) {
    Iterable zonesPayload = jsonDecode(zonesResponse);
    Iterable<ZoneModel> zones = zonesPayload.map((zone) {
      try {
        return new ZoneModel(
          identifier: zone['identifier'],
          latitude: double.parse(zone['latitude']),
          longitude: double.parse(zone['longitude']),
          radius: double.parse(zone['radius']),
          uiId: zone['uiId'],
          id: zone['id']
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
  ZoneModel activeZone = store.state.zones.zones[activeMarkerUiId];
  store.dispatch(SaveZoneRequest());
  activeZone.identifier = identifier;

  try {
    Response<Map<String, dynamic>> response = await httpService.post('/users/zone', data: activeZone.toMap());

    ZoneModel zone = ZoneModel(
          identifier: response.data['identifier'],
          latitude: response.data['latitude'],
          longitude: response.data['longitude'],
          radius: response.data['radius'].toDouble(),
          uiId: response.data['uiId'],
          id: response.data['id']
        );

    store.dispatch(SaveZoneSuccess(zone: zone));
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
      // TODO: update ID from the response
      Map<String, ZoneModel> zones = state.zones;
      zones[action.zone.uiId] = action.zone;

      return state.clone(
        network: NetworkState.success(),
        zones: zones,
      );

    case SaveZoneFailure:
      return state.clone(
          network: NetworkState.failure(errorMessage: ''),
          activeMarkerUiId: state.activeMarkerUiId);

    case AddActiveZone:
      Map<String, ZoneModel> newZones = Map<String, ZoneModel>.from(state.zones);
      newZones[action.uiId] = new ZoneModel(
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
      Map<String, ZoneModel> newZones = Map<String, ZoneModel>.from(state.zones);
      newZones.remove(action.uiId);

      return state.clone(zones: newZones, activeMarkerUiId: null);

    case EditActiveZone:
      Map<String, ZoneModel> newZones = Map<String, ZoneModel>.from(state.zones);
      ZoneModel target = newZones[state.activeMarkerUiId];
      target.radius = action.radius;
      return state.clone(
          zones: newZones, activeMarkerUiId: state.activeMarkerUiId);
  }

  return state;
}
