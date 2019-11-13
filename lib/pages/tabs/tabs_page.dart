import 'package:automate_ui/pages/login/zones_map_page.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:automate_ui/store/zones/reducer.dart';
import 'package:uuid/uuid.dart';

final uuid = new Uuid();

class TabsPage extends StatefulWidget {
  @override
  State<TabsPage> createState() => TabsPageState();
}

class TabsPageState extends State<TabsPage> {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, void>(
        onInit: (store) {
          getZonesRequest(store);
        },
        converter: (store) {},
        builder: (context, viewModel) {
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
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
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Icon(Icons.directions_transit),
                  Icon(Icons.directions_bike),
                  ZonesMapPage(),
                ],
              ),
            ),
          );
        });
  }
}
