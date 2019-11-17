import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'event_model.dart';

final AuthService authService = new AuthService();

class EventsState {
  final Map<String, Event> events;
  final NetworkState network;

  const EventsState({
    this.events = const {},
    this.network = const NetworkState(),
  });

  EventsState clone(
      {Map<String, Event> events,
      NetworkState network}) {
    return new EventsState(
        events: events ?? this.events,
        network: network ?? this.network,
        );
  }
}

class GetEventsRequest {}

class GetEventsSuccess {
  final Map<String, Event> events;

  GetEventsSuccess(this.events);
}

class GetEventsFailure {}

ThunkAction<AppState> getEventsRequest() {
  return (Store<AppState> store) async {
    store.dispatch(GetEventsRequest());

    try {
      Response<List> response = await httpService.get('/events');
      var automations = List<Event>.from(response.data.map((automation) => Event.fromMap(automation)));

      store.dispatch(GetEventsSuccess(Map.fromIterable(automations,
        key: (automation) => automation.id, value: (automation) => automation)));
    } catch (e) {
      store.dispatch(GetEventsFailure());
    }

  };
}


EventsState eventsReducer(EventsState state, action) {
  switch (action.runtimeType) {
    case GetEventsRequest:
      return state.clone(network: NetworkState.request());

    case GetEventsSuccess:
      return state.clone(network: NetworkState.success(), events: action.events);

    case GetEventsFailure:
      return state.clone(network: NetworkState.failure(errorMessage: ''));
  }

  return state;
}
