import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:dio/dio.dart';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'automation_model.dart';

final AuthService authService = new AuthService();

class AutomationsState {
  final Map<String, Automation> automations;
  final NetworkState network;

  const AutomationsState({
    this.automations = const {},
    this.network = const NetworkState(),
  });

  AutomationsState clone(
      {Map<String, Automation> automations,
      NetworkState network}) {
    return new AutomationsState(
        automations: automations ?? this.automations,
        network: network ?? this.network,
        );
  }
}

class GetAutomationsRequest {}

class GetAutomationsSuccess {
  final Map<String, Automation> automations;

  GetAutomationsSuccess(this.automations);
}

class GetAutomationsFailure {}

ThunkAction<AppState> getAutomationsRequest() {
  return (Store<AppState> store) async {
    store.dispatch(GetAutomationsRequest());

    try {
      Response<List> response = await httpService.get('/automations');
      var automations = List<Automation>.from(response.data.map((automation) => Automation.fromMap(automation)));

      store.dispatch(GetAutomationsSuccess(Map.fromIterable(automations,
        key: (automation) => automation.id, value: (automation) => automation)));
    } catch (e) {
      store.dispatch(GetAutomationsFailure());
    }

  };
}


AutomationsState automationsReducer(AutomationsState state, action) {
  switch (action.runtimeType) {
    case GetAutomationsRequest:
      return state.clone(network: NetworkState.request());

    case GetAutomationsSuccess:
      return state.clone(network: NetworkState.success(), automations: action.automations);

    case GetAutomationsFailure:
      return state.clone(network: NetworkState.failure(errorMessage: ''));
  }

  return state;
}
