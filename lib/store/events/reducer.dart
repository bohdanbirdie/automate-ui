import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'create_event_dto.dart';
import 'event_model.dart';

final AuthService authService = new AuthService();

class EventsState {
  final Map<String, Event> events;
  final NetworkState network;
  final NetworkState createNetwork;

  const EventsState({
    this.events = const {},
    this.network = const NetworkState(),
    this.createNetwork = const NetworkState(),
  });

  EventsState clone({
    Map<String, Event> events,
    NetworkState network,
    NetworkState createNetwork,
  }) {
    return new EventsState(
      events: events ?? this.events,
      network: network ?? this.network,
      createNetwork: createNetwork ?? this.createNetwork,
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
      var automations = List<Event>.from(
          response.data.map((automation) => Event.fromMap(automation)));

      store.dispatch(GetEventsSuccess(Map.fromIterable(automations,
          key: (automation) => automation.id,
          value: (automation) => automation)));
    } catch (e) {
      store.dispatch(GetEventsFailure());
    }
  };
}

class SaveEventRequest {}

class SaveEventSuccess {
  final Event event;

  SaveEventSuccess({
    @required this.event,
  });
}

class SaveEventFailure {}

ThunkAction<AppState> saveEventRequest(CreateEventDto createEventDto) {
  return (Store<AppState> store) async {
    store.dispatch(SaveEventRequest());

    try {
      Response<Map<String, dynamic>> response = await httpService.post(
        '/events',
        data: createEventDto.toMap(),
      );

      store.dispatch(SaveEventSuccess(event: Event.fromMap(response.data)));
      store.dispatch(NavigateToAction.pop());
    } catch (e) {
      print(e);
      store.dispatch(SaveEventFailure());
    }
  };
}

EventsState eventsReducer(EventsState state, action) {
  switch (action.runtimeType) {
    case GetEventsRequest:
      return state.clone(network: NetworkState.request());

    case GetEventsSuccess:
      return state.clone(
          network: NetworkState.success(), events: action.events);

    case GetEventsFailure:
      return state.clone(network: NetworkState.failure(errorMessage: ''));

    case SaveEventRequest:
      return state.clone(createNetwork: NetworkState.request());

    case SaveEventSuccess:
      Map<String, Event> events = Map.from(state.events);
      events[action.event.id] = action.event;

      return state.clone(createNetwork: NetworkState.success(), events: events);

    case SaveEventFailure:
      return state.clone(createNetwork: NetworkState.failure(errorMessage: ''));
  }

  return state;
}
