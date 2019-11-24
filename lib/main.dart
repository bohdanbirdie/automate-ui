import 'package:automate_ui/pages/login/login_page.dart';
import 'package:automate_ui/pages/media/media_page.dart';
import 'package:automate_ui/pages/tabs/tabs_page.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/services/http_service.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:automate_ui/widgets/quick_actions_manager.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

void main() {
  final store = new Store<AppState>(appStateReducer,
      initialState: new AppState(),
      middleware: [
        new LoggingMiddleware.printer(),
        thunkMiddleware,
        NavigationMiddleware<AppState>()
      ]);

  httpService.transformer = new FlutterTransformer();
  AuthService.store = store;

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
  Widget build(BuildContext context) {
    return new StoreProvider<AppState>(
      store: widget.store,
      child: QuickActionsManager(
        child: new MaterialApp(
          theme: new ThemeData.light(),
          navigatorKey: NavigatorHolder.navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (context) => LoginPage(),
            '/tabs': (context) => TabsPage(),
            '/media': (context) => MediaPage(),
          },
        ),
      ),
    );
  }
}
