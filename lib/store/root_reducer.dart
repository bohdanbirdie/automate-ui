import 'package:automate_ui/store/auth/reducer.dart';

class AppState {
  final AuthState auth;
  final String searchQuery;

  AppState({ this.auth = const AuthState(), this.searchQuery = '' });
}

class PerformSearchAction {
  String query;
}


String searchQueryReducer(String searchQuery, action) {
  return action is PerformSearchAction ? action.query : searchQuery;
}

AppState appStateReducer(AppState state, action) => new AppState(
  auth: authReducer(state.auth, action),
  searchQuery: searchQueryReducer(state.searchQuery, action)
);