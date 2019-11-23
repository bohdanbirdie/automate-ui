import 'package:automate_ui/store/automations/create_automation_dto.dart';
import 'package:automate_ui/store/automations/reducer.dart';
import 'package:automate_ui/store/events/event_model.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:automate_ui/store/zones/zone_model.dart';
import 'package:automate_ui/widgets/loading_overlay.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class AddNewAutomationPage extends StatefulWidget {
  AddNewAutomationPage({Key key}) : super(key: key);

  @override
  _AddNewAutomationPageState createState() => _AddNewAutomationPageState();
}

class _AddNewAutomationPageState extends State<AddNewAutomationPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  List<String> addedZonesIds = List();
  List<String> addedEventsIds = List();

  Widget _buildZoneListItem(ZoneModel zone) {
    // TODO: refactor for DRY
    Widget zoneWidget = Container(
        child: ListTile(
          title: Text(zone.identifier),
        ),
        decoration: new BoxDecoration(
            color: Theme.of(context).splashColor,
            border: new Border(
              bottom: new BorderSide(color: Theme.of(context).primaryColor),
            )));

    return ExpandableNotifier(
      child: Column(
        children: [
          Expandable(
            collapsed: ExpandableButton(
              child: Container(
                child: zoneWidget,
              ),
            ),
            expanded: Column(children: [
              ExpandableButton(
                child: zoneWidget,
              ),
              FormBuilderCheckboxList(
                attribute: zone.id,
                initialValue: ['onEnter', 'onLeave'],
                options: [
                  FormBuilderFieldOption(
                      label: 'On zone enter', value: "onEnter"),
                  FormBuilderFieldOption(
                      label: 'On zone leave', value: "onLeave"),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEventsList(_ViewModel viewModel) {
    List<Widget> zonesItems = addedEventsIds.where((eventId) {
      return viewModel.events[eventId] != null;
    }).map((eventId) {
      Event event = viewModel.events[eventId];
      return Container(
          child: ListTile(
            title: Text(event.name),
          ),
          decoration: new BoxDecoration(
              color: Theme.of(context).splashColor,
              border: new Border(
                bottom: new BorderSide(color: Theme.of(context).primaryColor),
              )));
    }).toList();

    zonesItems.insert(
        0,
        Container(
            child: ListTile(
          leading: Icon(
            Icons.event,
            color: Theme.of(context).indicatorColor,
          ),
          title: Text(
            'Events',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )));

    if (zonesItems.length == 1) {
      zonesItems.add(Container(
        child: ListTile(
          title: Text("No events connected"),
        ),
      ));
    }

    zonesItems.add(Container(
        child: ListTile(
      leading: Icon(
        Icons.add_circle,
        color: Theme.of(context).indicatorColor,
      ),
      key: Key('add_one'),
      title: Text('Connect event'),
      onTap: () {
        _openEventsList(viewModel);
      },
    )));

    return zonesItems;
  }

  List<Widget> _buildZonesList(_ViewModel viewModel) {
    var zonesItems = addedZonesIds.where((zoneId) {
      return viewModel.zones[zoneId] != null;
    }).map((zoneId) {
      ZoneModel zone = viewModel.zones[zoneId];
      return _buildZoneListItem(zone);
    }).toList();

    zonesItems.insert(
        0,
        ListTile(
          leading: Icon(
            Icons.location_on,
            color: Theme.of(context).indicatorColor,
          ),
          title: Text(
            'Zones',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ));

    if (zonesItems.length == 1) {
      zonesItems.add(Container(
        child: ListTile(
          title: Text("No zones connected"),
        ),
      ));
    }

    zonesItems.add(ListTile(
      leading: Icon(
        Icons.add_circle,
        color: Theme.of(context).indicatorColor,
      ),
      key: Key('add_one'),
      title: Text('Connect zone'),
      onTap: () {
        _openZonesList(viewModel);
      },
    ));

    return zonesItems;
  }

  void _openZonesList(_ViewModel viewModel) {
    List<Widget> options = viewModel.zones.values.where((zone) {
      bool foundZone = addedZonesIds
          .contains(zone.id);

      return !foundZone;
    }).map((zone) {
      return SimpleDialogOption(
        child: Text(zone.identifier),
        onPressed: () {
          setState(() {
            addedZonesIds.add(zone.id);
          });
          Navigator.of(context).pop();
        },
      );
    }).toList();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Choose a Zone to connect'),
            children: options,
          );
        });
  }

  void _openEventsList(_ViewModel viewModel) {
    List<Widget> options = viewModel.events.values.where((event) {
      bool foundEvent = addedEventsIds.contains(event.id);

      return !foundEvent;
    }).map((event) {
      return SimpleDialogOption(
        child: Text(event.name),
        onPressed: () {
          setState(() {
            addedEventsIds.add(event.id);
          });
          Navigator.of(context).pop();
        },
      );
    }).toList();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Choose a Event to connect'),
            children: options,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(
      converter: (store) {
        return new _ViewModel.fromStore(store);
      },
      builder: (context, viewModel) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Add new automation'),
            ),
            body: Stack(
              children: <Widget>[
                SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FormBuilder(
                      key: _fbKey,
                      initialValue: {
                        'name': "Name test",
                        'description': "Description test",
                      },
                      autovalidate: true,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10.0),
                          FormBuilderTextField(
                            attribute: "name",
                            decoration:
                                InputDecoration(labelText: "Automation name"),
                            validators: [FormBuilderValidators.minLength(5)],
                          ),
                          SizedBox(height: 10.0),
                          FormBuilderTextField(
                            attribute: "description",
                            decoration:
                                InputDecoration(labelText: "Description"),
                            validators: [FormBuilderValidators.minLength(10)],
                          ),
                          SizedBox(height: 10.0),
                          Column(children: _buildEventsList(viewModel)),
                          SizedBox(height: 30.0),
                          Column(children: _buildZonesList(viewModel)),
                          SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        MaterialButton(
                          child: Text("Submit"),
                          onPressed: () {
                            if (_fbKey.currentState.saveAndValidate()) {
                              CreateAutomationDto payload =
                                  new CreateAutomationDto(
                                description:
                                    _fbKey.currentState.value['description'],
                                name: _fbKey.currentState.value['name'],
                                zonesIds: addedZonesIds,
                                eventsIds: addedEventsIds,
                                payload: _fbKey.currentState.value,
                              );

                              viewModel.saveAutomation(payload);
                            }
                          },
                        ),
                        MaterialButton(
                          child: Text("Reset"),
                          onPressed: () {
                            _fbKey.currentState.reset();
                          },
                        ),
                      ],
                    )
                  ],
                )),
                LoadingOverlay(loading: viewModel.createLoading)
              ],
            ));
      },
    );
  }
}

class _ViewModel {
  final Map<String, ZoneModel> zones;
  final Map<String, Event> events;
  final Function(CreateAutomationDto payload) saveAutomation;
  final bool createLoading;

  _ViewModel._({
    @required this.zones,
    @required this.events,
    @required this.saveAutomation,
    @required this.createLoading,
  });

  factory _ViewModel.fromStore(Store<AppState> store) {
    final Map<String, ZoneModel> zones =
        (store.state.zones.zones ?? Map()).map((key, value) {
      return MapEntry(value.id, value);
    });
    final Map<String, Event> events = store.state.events.events ?? Map();

    return _ViewModel._(
        createLoading: store.state.automations.createNetwork.loading,
        zones: zones,
        events: events,
        saveAutomation: (CreateAutomationDto payload) {
          store.dispatch(saveAutomationsRequest(payload));
        });
  }
}
