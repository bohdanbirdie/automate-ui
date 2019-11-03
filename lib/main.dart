import 'package:automate_ui/pages/login/login_page.dart';
import 'package:automate_ui/pages/tabs/tabs_page.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';


loggingMiddleware(Store<AppState> store, action, NextDispatcher next) {
  print('${new DateTime.now()}: $action');

  next(action);
}

void main() {
  final store = new Store<AppState>(
    appStateReducer,
    initialState: new AppState(),
    middleware: [loggingMiddleware, thunkMiddleware, NavigationMiddleware<AppState>()]
  );

  HttpService.store = store;

  runApp(new ConnectedApp(
    store: store,
  ));
}

class ConnectedApp extends StatelessWidget {
  final Store<AppState> store;
  final String title;

  ConnectedApp({Key key, this.store, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<AppState>(
      store: store,
      child: new MaterialApp(
        theme: new ThemeData.dark(),
        navigatorKey: NavigatorHolder.navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/tabs': (context) => TabsPage(),
        },
      ),
    );
  }
}