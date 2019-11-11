import 'package:automate_ui/services/http_service.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String TOKEN_KEY = 'JWT_TOKEN';
final HttpService httpService = new HttpService();

class AuthService {

  AuthService._privateConstructor();

  static final AuthService _instance = AuthService._privateConstructor();

  factory AuthService(){
    return _instance;
  }

  Future<bool> validateSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString(TOKEN_KEY);

    if (token != null) {
      try {
        Response response = await httpService.get('http://localhost:3000/users/profile', headers: { 'Authorization': 'Bearer $token'});

        if (response.statusCode != 200) {
          throw Exception();
        } else {
          return true;
        }
      } catch (e) {
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