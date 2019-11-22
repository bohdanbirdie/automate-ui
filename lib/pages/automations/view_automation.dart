import 'package:automate_ui/store/automations/automation_model.dart';
import 'package:automate_ui/store/events/event_model.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:automate_ui/store/zones/reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class ViewAutomationPage extends StatefulWidget {
  final String automationId;
  ViewAutomationPage({@required this.automationId});

  @override
  _ViewAutomationPageState createState() => _ViewAutomationPageState();
}

class _ViewAutomationPageState extends State<ViewAutomationPage> {
  Widget _renderTitle(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
    );
  }

  Widget _renderZoneTile(Zone zone, _ViewModel _viewModel) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(zone.identifier),
        ),
        Container(
          color: Theme.of(context).selectedRowColor,
          child: Row(
            children: <Widget>[
              Visibility(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Chip(
                    label: Text('On Enter'),
                  ),
                ),
                visible: _viewModel.zonesMarkers[zone.id]['onEnter'],
              ),
              Visibility(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Chip(
                    label: Text('On Leave'),
                  ),
                ),
                visible: _viewModel.zonesMarkers[zone.id]['onLeave'],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _renderEventTile(Event event, _ViewModel _viewModel) {
    return ListTile(
      title: Text(event.name),
    );
  }

  Widget _renderList<T>(
    List<T> items,
    Function(T item, _ViewModel _viewModel) renderTile,
    _ViewModel _viewModel,
  ) {
    List<Widget> ties = items.map((item) {
      return Container(
          child: renderTile(item, _viewModel),
          decoration: new BoxDecoration(
              color: Theme.of(context).splashColor,
              border: new Border(
                bottom: new BorderSide(color: Theme.of(context).primaryColor),
              )));
    }).toList();

    return Column(
      children: ties,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(
      converter: (store) {
        return new _ViewModel.fromStore(store, widget.automationId);
      },
      builder: (context, viewModel) {
        return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.automation.name),
            ),
            body: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _renderTitle("Description"),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(viewModel.automation.description),
                          ),
                          Visibility(
                            visible: viewModel.zones.length > 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 40,
                                ),
                                _renderTitle("Zones"),
                                _renderList<Zone>(viewModel.zones,
                                    _renderZoneTile, viewModel),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: viewModel.events.length > 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 40,
                                ),
                                _renderTitle("Events"),
                                _renderList<Event>(viewModel.events,
                                    _renderEventTile, viewModel),
                              ],
                            ),
                          )
                        ]),
                  ),
                )
              ],
            ));
      },
    );
  }
}

class _ViewModel {
  final Automation automation;
  final List<Zone> zones;
  final List<Event> events;
  final Map<String, Map<String, bool>> zonesMarkers;

  _ViewModel._({
    @required this.automation,
    @required this.zones,
    @required this.events,
    @required this.zonesMarkers,
  });

  factory _ViewModel.fromStore(Store<AppState> store, String automationId) {
    final Automation automation =
        store.state.automations.automations[automationId];

    final Map<String, Zone> zones =
        (store.state.zones.zones ?? Map()).map((key, value) {
      return MapEntry(value.id, value);
    });

    final List<Zone> relatedZones = automation.automationZones.map((zone) {
      return zones[zone.zoneId];
    }).where((zone) {
      return zone != null;
    }).toList();

    final Map<String, Map<String, bool>> zonesMarkers = new Map();
    automation.automationZones.forEach((aZone) {
      zonesMarkers[aZone.zoneId] = {
        'onEnter': aZone.onEnter,
        'onLeave': aZone.onLeave,
      };
    });
    print('relatedZones $relatedZones');
    final Map<String, Event> events = store.state.events.events ?? Map();

    final List<Event> relatedEvents = automation.automationEvents.map((event) {
      return events[event.eventId];
    }).toList();

    return _ViewModel._(
      automation: automation,
      zones: relatedZones,
      events: relatedEvents,
      zonesMarkers: zonesMarkers,
    );
  }
}
