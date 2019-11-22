import 'package:automate_ui/helpers/constants.dart';
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

  factory AuthService(){
    return _instance;
  }

  Future<bool> validateSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString(TOKEN_KEY);

    if (token != null) {
      try {
        Response response = await httpService.get('/users/profile', options: Options(headers: { 'Authorization': 'Bearer $token'}));

        if (response.statusCode != 200) {
          // throw Exception();
          prefs.remove(TOKEN_KEY);
          return false;
        } else {
          if (AuthService.store != null) {
            AuthService.store.dispatch(LoginRequestSuccess(token));
          }
          return true;
        }
      } catch (e) {
        prefs.remove(TOKEN_KEY);
        return false;
      }
    }

    return false;
  }

  void saveSession(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();    

    prefs.setString(TOKEN_KEY, token);
  }

}