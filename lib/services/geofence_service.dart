import 'package:automate_ui/helpers/constants.dart';
import 'package:automate_ui/store/zones/zone_model.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class GeofenceService {
  GeofenceService._();

  static List<bg.Geofence> _zonesQueue = List();

  static bool _isReady = false;
  static bool _isLoading = false;

  static Future<void> startPlugin(String token) async {
    if (!_isReady && !_isLoading) {
      _isLoading = true;

      await bg.BackgroundGeolocation.ready(
        bg.Config(
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
          distanceFilter: 10.0,
          geofenceInitialTriggerEntry: false,
          stopOnTerminate: false,
          
          disableElasticity: true,
          geofenceModeHighAccuracy: true,
          startOnBoot: true,
          url: '${hostname}geofences',
          autoSync: true,
          debug: true,
          logLevel: bg.Config.LOG_LEVEL_OFF,
          persistMode: bg.Config.PERSIST_MODE_GEOFENCE,
          reset: true,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      await bg.BackgroundGeolocation.start();
      _isReady = true;
      _isLoading = false;

      if (_zonesQueue.length > 0) {
        setZones(_zonesQueue);
      }
    }
  }

  static Future<void> setZones(List<ZoneModel> zones) async {
    List<bg.Geofence> geofences = zones.map((zone) {
      return zone.geofence();
    }).toList();

    if (_isReady) {
      await revomeZones();

      try {
        await bg.BackgroundGeolocation.addGeofences(geofences);
        _zonesQueue = List();
      } catch (e) {
        print('failed to add geofences');
      }
    } else {
      _zonesQueue.addAll(geofences);
    }
  }

  static Future<bool> revomeZones() async {
    try {
      bool result = await bg.BackgroundGeolocation.removeGeofences();

      return result;
    } catch (e) {
      print('failed to remove geofences');
      return false;
    }
  }
}
