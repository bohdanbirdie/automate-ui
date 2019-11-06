import 'package:automate_ui/pages/login/login_page.dart';
import 'package:automate_ui/pages/tabs/tabs_page.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'dart:convert';
JsonEncoder encoder = new JsonEncoder.withIndent("     ");

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

// class ConnectedApp extends StatefulWidget {
//   final Store<AppState> store;
//   final String title;

//   ConnectedApp({Key key, this.store, this.title}) : super(key: key);

//   @override
//   _ConnectedAppState createState() => _ConnectedAppState();
// }

// class _ConnectedAppState extends State<ConnectedApp> {
//   bool _isMoving;
//   bool _enabled;
//   String _motionActivity;
//   String _odometer;
//   String _content;

//   @override
//   void initState() {
//     _isMoving = false;
//     _enabled = false;
//     _content = '';
//     _motionActivity = 'UNKNOWN';
//     _odometer = '0';

//     // 1.  Listen to events (See docs for all 12 available events).
//     bg.BackgroundGeolocation.onLocation(_onLocation);
//     bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
//     bg.BackgroundGeolocation.onActivityChange(_onActivityChange);
//     bg.BackgroundGeolocation.onProviderChange(_onProviderChange);
//     bg.BackgroundGeolocation.onConnectivityChange(_onConnectivityChange);
//     bg.BackgroundGeolocation.onHttp((bg.HttpEvent response) {
//       print('[http] success? ${response.success}, status? ${response.status}');
//     });

//     // 2.  Configure the plugin
//     bg.BackgroundGeolocation.ready(bg.Config(
//         desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
//         distanceFilter: 10.0,
//         stopOnTerminate: false,
//         startOnBoot: true,
//         url: 'http://localhost:3000/location',
//         autoSync: true,
//         // httpMethod: 'POST',
//         debug: true,
//         logLevel: bg.Config.LOG_LEVEL_VERBOSE,
//         reset: true
//     )).then((bg.State state) {
//       setState(() {
//         _enabled = state.enabled;
//         _isMoving = state.isMoving;
//       });
//     });
//   }

//   void _onClickEnable(enabled) {
//     if (enabled) {
//       bg.BackgroundGeolocation.start().then((bg.State state) {
//         print('[start] success $state');
//         setState(() {
//           _enabled = state.enabled;
//           _isMoving = state.isMoving;
//         });
//       });
//     } else {
//       bg.BackgroundGeolocation.stop().then((bg.State state) {
//         print('[stop] success: $state');
//         // Reset odometer.
//         bg.BackgroundGeolocation.setOdometer(0.0);

//         setState(() {
//           _odometer = '0.0';
//           _enabled = state.enabled;
//           _isMoving = state.isMoving;
//         });
//       });
//     }
//   }

//   // Manually toggle the tracking state:  moving vs stationary
//   void _onClickChangePace() {
//     setState(() {
//       _isMoving = !_isMoving;
//     });
//     print("[onClickChangePace] -> $_isMoving");

//     bg.BackgroundGeolocation.changePace(_isMoving).then((bool isMoving) {
//       print('[changePace] success $isMoving');
//     }).catchError((e) {
//       print('[changePace] ERROR: ' + e.code.toString());
//     });
//   }

//   // Manually fetch the current position.
//   void _onClickGetCurrentPosition() {
//     bg.BackgroundGeolocation.getCurrentPosition(
//         persist: false,     // <-- do not persist this location
//         desiredAccuracy: 0, // <-- desire best possible accuracy
//         timeout: 30000,     // <-- wait 30s before giving up.
//         samples: 3          // <-- sample 3 location before selecting best.
//     ).then((bg.Location location) {
//       print('[getCurrentPosition] - $location');
//     }).catchError((error) {
//       print('[getCurrentPosition] ERROR: $error');
//     });
//   }

//   ////
//   // Event handlers
//   //

//   void _onLocation(bg.Location location) {
//     print('[location] - $location');

//     String odometerKM = (location.odometer / 1000.0).toStringAsFixed(1);

//     setState(() {
//       _content = encoder.convert(location.toMap());
//       _odometer = odometerKM;
//     });
//   }

//   void _onMotionChange(bg.Location location) {
//     print('[motionchange] - $location');
//   }

//   void _onActivityChange(bg.ActivityChangeEvent event) {
//     print('[activitychange] - $event');
//     setState(() {
//       _motionActivity = event.activity;
//     });
//   }

//   void _onProviderChange(bg.ProviderChangeEvent event) {
//     print('$event');

//     setState(() {
//       _content = encoder.convert(event.toMap());
//     });
//   }

//   void _onConnectivityChange(bg.ConnectivityChangeEvent event) {
//     print('$event');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       title: 'BackgroundGeolocation Demo',
//       theme: new ThemeData(
//         primarySwatch: Colors.amber,
//       ),
//       home: Scaffold(
//       appBar: AppBar(
//         title: const Text('Background Geolocation'),
//         actions: <Widget>[
//           Switch(
//             value: _enabled,
//             onChanged: _onClickEnable
//           ),
//         ]
//       ),
//       body: SingleChildScrollView(
//           child: Text('$_content')
//       ),
//       bottomNavigationBar: BottomAppBar(
//         child: Container(
//           padding: const EdgeInsets.only(left: 5.0, right: 5.0),
//           child: Row(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               IconButton(
//                 icon: Icon(Icons.gps_fixed),
//                 onPressed: _onClickGetCurrentPosition,
//               ),
//               Text('$_motionActivity · $_odometer km'),
//               MaterialButton(
//                 minWidth: 50.0,
//                 child: Icon((_isMoving) ? Icons.pause : Icons.play_arrow, color: Colors.white),
//                 color: (_isMoving) ? Colors.red : Colors.green,
//                 onPressed: _onClickChangePace
//               )
//             ]
//           )
//         )
//       ),
//     )
//     );
//   }
//   // @override
//   // Widget build(BuildContext context) {
//   //   return new StoreProvider<AppState>(
//   //     store: widget.store,
//   //     child: new MaterialApp(
//   //       theme: new ThemeData.dark(),
//   //       navigatorKey: NavigatorHolder.navigatorKey,
//   //       initialRoute: '/',
//   //       routes: {
//   //         '/': (context) => LoginPage(),
//   //         '/tabs': (context) => TabsPage(),
//   //       },
//   //     ),
//   //   );
//   // }
// }