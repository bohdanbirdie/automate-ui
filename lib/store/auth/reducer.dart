import 'dart:convert';

import 'package:automate_ui/helpers/constants.dart';
import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/services/geofence_service.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';
import 'package:http/http.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

final AuthService authService = new AuthService();

class AuthState {
  final String userToken;
  final NetworkState network;

  const AuthState({this.userToken, this.network = const NetworkState()});

  AuthState clone({String userToken, NetworkState network}) {
    userToken = userToken ?? this.userToken;
    network = network ?? this.network;
    return new AuthState(userToken: userToken, network: network);
  }
}

class LoginRequest {}

class LoginRequestSuccess {
  String token;

  LoginRequestSuccess(this.token);
}

class LoginRequestFailure {
  String error;

  LoginRequestFailure(this.error);
}

class RemoveUserToken {
  String token;
}

ThunkAction<AppState> loginUserAction(
    String username, String password, bool isRegistration) {
  return (Store<AppState> store) async {
    store.dispatch(LoginRequest());

    String endpoint =
        isRegistration ? '${hostname}auth/register' : '${hostname}auth/login';

    try {
      Response response = await post(
        endpoint,
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 403) {
        throw new Exception('Such user already exist');
      }

      if (response.statusCode != 201) {
        throw new Exception(
            'Failed to ${isRegistration ? 'register' : 'login'}');
      }

      Map<String, dynamic> session = jsonDecode(response.body);
      authService.saveSession(session['access_token']);

      await GeofenceService.startPlugin(session['access_token']);

      store.dispatch(LoginRequestSuccess(session['access_token']));
      store.dispatch(NavigateToAction.replace('/tabs'));
    } on Exception catch (e) {
      store.dispatch(LoginRequestFailure(e.toString()));
    }
  };
}

AuthState authReducer(AuthState state, action) {
  if (action is LoginRequest) {
    return state.clone(network: NetworkState.request());
  } else if (action is LoginRequestSuccess) {
    String token = action.token;
    httpService.options.headers.addAll({'Authorization': 'Bearer ${token}'});

    return state.clone(
        userToken: action.token, network: NetworkState.success());
  } else if (action is LoginRequestFailure) {
    return state.clone(
        network: NetworkState.failure(errorMessage: action.error));
  } else {
    return state;
  }
}
