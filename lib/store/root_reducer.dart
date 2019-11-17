import 'package:automate_ui/store/auth/reducer.dart';
import 'package:automate_ui/store/automations/reducer.dart';
import 'package:automate_ui/store/events/reducer.dart';
import 'package:automate_ui/store/zones/reducer.dart';

class AppState {
  final AuthState auth;
  final AutomationsState automations;
  final EventsState events;
  final ZonesState zones;
  final String searchQuery;

  AppState(
      {this.auth = const AuthState(),
      this.zones = const ZonesState(),
      this.events = const EventsState(),
      this.automations = const AutomationsState(),
      this.searchQuery = ''});
}

class PerformSearchAction {
  String query;
}

String searchQueryReducer(String searchQuery, action) {
  return action is PerformSearchAction ? action.query : searchQuery;
}

AppState appStateReducer(AppState state, action) => new AppState(
    auth: authReducer(state.auth, action),
    zones: zonesReducer(state.zones, action),
    automations: automationsReducer(state.automations, action),
    events: eventsReducer(state.events, action),
);
