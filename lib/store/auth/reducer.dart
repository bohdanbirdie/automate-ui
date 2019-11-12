import 'dart:convert';

import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';
import 'package:http/http.dart';
import 'package:redux/redux.dart';

final HttpService httpService = new HttpService();
final AuthService authService = new AuthService();

class AuthState {
  final String userToken;
  final NetworkState network;

  const AuthState({ this.userToken, this.network = const NetworkState() });

  AuthState clone({ String userToken, NetworkState network }) {
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

void loginUserAction(Store<AppState> store, String username, String password) async {
  store.dispatch(LoginRequest());

  try {
    var url = 'http://localhost:3000/auth/login';
    Response response = await httpService.post(url, body: { 'username': username, 'password': password });

    if (response.statusCode != 201 ) {      
      throw new Exception('Failed to login');
    }

    Map<String, dynamic> user = jsonDecode(response.body);
    authService.saveSession(user['access_token']);

    store.dispatch(LoginRequestSuccess(user['access_token']));
    store.dispatch(NavigateToAction.replace('/tabs'));
  } on Exception catch (e) {
    store.dispatch(LoginRequestFailure(e.toString()));
  }
}

AuthState authReducer(AuthState state, action) {
  if (action is LoginRequest) {
    return state.clone(network: NetworkState.request());
  } else if (action is LoginRequestSuccess) {
    return state.clone(userToken: action.token, network: NetworkState.success());
  } else if (action is LoginRequestFailure) {
    return state.clone(network: NetworkState.failure(errorMessage: action.error));
  } else {
    return state;
  }
}