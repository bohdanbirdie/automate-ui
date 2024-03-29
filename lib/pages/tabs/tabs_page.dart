import 'package:automate_ui/pages/automations/add_new_automation.dart';
import 'package:automate_ui/pages/automations/automations_page.dart';
import 'package:automate_ui/pages/events/add_new_event.dart';
import 'package:automate_ui/pages/events/events_page.dart';
import 'package:automate_ui/pages/zones/zones_map_page.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/store/automations/reducer.dart';
import 'package:automate_ui/store/events/reducer.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:automate_ui/store/zones/reducer.dart';
import 'package:uuid/uuid.dart';

final uuid = new Uuid();
final AuthService authService = new AuthService();

class TabsPage extends StatefulWidget {
  @override
  State<TabsPage> createState() => TabsPageState();
}

class TabsPageState extends State<TabsPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int activeIndex = 0;

  @override
  void initState() {
    _tabController =
        new TabController(length: 3, vsync: this, initialIndex: activeIndex);
    _tabController.addListener(() {
      setState(() {
        activeIndex = _tabController.index;
      });
    });

    super.initState();
  }

  List<Widget> _getBarAction() {
    return [
      Visibility(
        visible: activeIndex == 1,
        child: IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).accentIconTheme.color,
            ),
            onPressed: () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AddNewEventDialog();
                  });
            }),
      ),
      Visibility(
        visible: activeIndex == 0,
        child: IconButton(
            icon: Icon(
              Icons.add_box,
              color: Theme.of(context).accentIconTheme.color,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNewAutomationPage()),
              );
            }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, void>(
        onInit: (store) {
          getZonesRequest(store);
          store.dispatch(getAutomationsRequest());
          store.dispatch(getEventsRequest());
        },
        converter: (store) {},
        builder: (context, viewModel) {
          return Stack(
            children: <Widget>[
              DefaultTabController(
                length: 3,
                child: Scaffold(
                  drawer: Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        DrawerHeader(
                          child: Text(
                            'Quick actions',
                            style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).accentIconTheme.color,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Logout',
                            style: TextStyle(fontSize: 20),
                          ),
                          onTap: () async {
                            await authService.logout();
                            Navigator.pushReplacementNamed(context, '/');
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Media page',
                            style: TextStyle(fontSize: 20),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/media');
                          },
                        ),
                      ],
                    ),
                  ),
                  appBar: AppBar(
                    actions: _getBarAction(),
                    bottom: TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(
                          icon: Icon(Icons.receipt),
                          text: "Automations",
                        ),
                        Tab(
                          icon: Icon(Icons.event),
                          text: "Events",
                        ),
                        Tab(
                          icon: Icon(Icons.location_on),
                          text: "Zones",
                        ),
                      ],
                    ),
                    title: Text('Automate'),
                  ),
                  body: TabBarView(
                    controller: _tabController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      AutomationsPage(),
                      EventsPage(),
                      ZonesMapPage(),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConnectionStatusBar(
                  height: 35,
                  color: Colors.redAccent.withOpacity(0.8),
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'Please check your internet connection',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
