import 'package:automate_ui/pages/automations/add_new_automation.dart';
import 'package:automate_ui/pages/automations/automations_page.dart';
import 'package:automate_ui/pages/events/add_new_event.dart';
import 'package:automate_ui/pages/events/events_page.dart';
import 'package:automate_ui/pages/zones/zones_map_page.dart';
import 'package:automate_ui/store/automations/reducer.dart';
import 'package:automate_ui/store/events/reducer.dart';
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
          return DefaultTabController(
            length: 3,
            child: Scaffold(
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
          );
        });
  }
}
