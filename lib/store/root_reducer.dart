import 'package:automate_ui/store/auth/reducer.dart';
import 'package:automate_ui/store/zones/reducer.dart';

class AppState {
  final AuthState auth;
  final ZonesState zones;
  final String searchQuery;

  AppState(
      {this.auth = const AuthState(),
      this.zones = const ZonesState(),
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
    searchQuery: searchQueryReducer(state.searchQuery, action));
