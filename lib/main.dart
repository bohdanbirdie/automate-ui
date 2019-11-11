import 'package:automate_ui/pages/login/login_page.dart';
import 'package:automate_ui/pages/tabs/tabs_page.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'dart:convert';

JsonEncoder encoder = new JsonEncoder.withIndent("     ");

loggingMiddleware(Store<AppState> store, action, NextDispatcher next) {
  print('${new DateTime.now()}: $action');

  next(action);
}


void main() {
  final store = new Store<AppState>(appStateReducer,
      initialState: new AppState(),
      middleware: [
        loggingMiddleware,
        thunkMiddleware,
        NavigationMiddleware<AppState>()
      ]);

  HttpService.store = store;

  runApp(new ConnectedApp(
      store: store,
      ));

}


class ConnectedApp extends StatefulWidget {
  final Store<AppState> store;
  final String title;

  ConnectedApp({Key key, this.store, this.title}) : super(key: key);

  @override
  _ConnectedAppState createState() => _ConnectedAppState();
}

class _ConnectedAppState extends State<ConnectedApp> {

  @override
  void initState() {

    bg.BackgroundGeolocation.ready(bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 10.0,
            geofenceInitialTriggerEntry: false,
            stopOnTerminate: false,
            startOnBoot: true,
            url: 'http://localhost:3000/location',
            autoSync: true,
            // httpMethod: 'POST',
            debug: false,
            logLevel: bg.Config.LOG_LEVEL_OFF,
            reset: true))
        .then((bg.State state) {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<AppState>(
      store: widget.store,
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
