import 'dart:convert';

import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:redux/redux.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

final HttpService httpService = new HttpService();
final AuthService authService = new AuthService();

class Zone extends bg.Geofence {
  final LatLng location;
  final String uiId;

  Zone(
      {@required String identifier,
      @required double radius,
      @required double latitude,
      @required double longitude,
      @required this.uiId,
      bool notifyOnEntry = true,
      bool notifyOnExit = true,
      bool notifyOnDwell = false,
      int loiteringDelay,
      Map<String, dynamic> extras})
      : location = new LatLng(latitude, longitude),
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

class LoginRequestSuccess {}

class LoginRequestFailure {}

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

void saveZoneRequest(
  Store<AppState> store,
) async {
  store.dispatch(SaveZoneRequest());

  // try {
  //   var url = 'http://localhost:3000/auth/login';
  //   Response response = await httpService
  //       .post(url, body: {'username': username, 'password': password});

  //   if (response.statusCode != 201) {
  //     throw new Exception('Failed to login');
  //   }

  //   Map<String, dynamic> user = jsonDecode(response.body);
  //   authService.saveSession(user['access_token']);

  //   store.dispatch(LoginRequestSuccess(user['access_token']));
  //   store.dispatch(NavigateToAction.replace('/tabs'));
  // } on Exception catch (e) {
  //   store.dispatch(LoginRequestFailure(e.toString()));
  // }
}

ZonesState zonesReducer(ZonesState state, action) {
  switch (action.runtimeType) {
    case SaveZoneRequest:
      return state.clone(network: NetworkState.request());

    case LoginRequestSuccess:
      return state.clone(network: NetworkState.success());

    case LoginRequestFailure:
      return state.clone(network: NetworkState.failure(errorMessage: ''));

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
