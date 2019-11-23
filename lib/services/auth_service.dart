import 'package:automate_ui/helpers/constants.dart';
import 'package:automate_ui/services/geofence_service.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/auth/reducer.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String TOKEN_KEY = 'JWT_TOKEN';

class AuthService {
  AuthService._privateConstructor();

  static final AuthService _instance = AuthService._privateConstructor();
  static Store<AppState> store;

  factory AuthService() {
    return _instance;
  }

  Future<bool> validateSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString(TOKEN_KEY);

    if (token != null) {
      try {
        Response response = await httpService.get('/refresh',
            options: Options(headers: {'Authorization': 'Bearer $token'}));

        if (response.statusCode != 200) {
          await prefs.remove(TOKEN_KEY);

          return false;
        } else {
          String newToken = response.data['access_token'];
          await prefs.setString(TOKEN_KEY, newToken);

          if (AuthService.store != null) {
            AuthService.store.dispatch(LoginRequestSuccess(newToken));
            await GeofenceService.startPlugin(newToken);
          }
          return true;
        }
      } catch (e) {
        await prefs.remove(TOKEN_KEY);
        await GeofenceService.revomeZones();

        return false;
      }
    }

    return false;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await GeofenceService.revomeZones();
  }

  void saveSession(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(TOKEN_KEY, token);
  }
}
