import 'package:automate_ui/store/events/create_event_dto.dart';
import 'package:automate_ui/store/events/reducer.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class AddNewEventDialog extends StatefulWidget {
  AddNewEventDialog({Key key}) : super(key: key);

  @override
  _AddNewEventDialogState createState() => _AddNewEventDialogState();
}

class _AddNewEventDialogState extends State<AddNewEventDialog> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(converter: (store) {
      return new _ViewModel.fromStore(store);
    }, builder: (context, viewModel) {
      return AlertDialog(
        title: Text('Enter Event name'),
        content: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: !viewModel.createLoading,
                child: FormBuilder(
                  key: _fbKey,
                  autovalidate: true,
                  child: FormBuilderTextField(
                    attribute: "name",
                    decoration: InputDecoration(labelText: "Event name"),
                    validators: [FormBuilderValidators.minLength(3)],
                  ),
                ),
              ),
              Visibility(
                visible: viewModel.createLoading,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Loading',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        actions: <Widget>[
          Visibility(
            child: FlatButton(
              child: new Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            visible: !viewModel.createLoading,
          ),
          new FlatButton(
            child: new Text('SAVE'),
            onPressed: () {
              if (_fbKey.currentState.saveAndValidate()) {
                CreateEventDto payload =
                    CreateEventDto(name: _fbKey.currentState.value['name']);
                viewModel.saveEvent(payload);
              }
            },
          )
        ],
      );
    });
  }
}

class _ViewModel {
  final Function(CreateEventDto payload) saveEvent;
  final bool createLoading;

  _ViewModel._({
    @required this.saveEvent,
    @required this.createLoading,
  });

  factory _ViewModel.fromStore(Store<AppState> store) {
    return _ViewModel._(
        createLoading: store.state.events.createNetwork.loading,
        saveEvent: (CreateEventDto payload) {
          store.dispatch(saveEventRequest(payload));
        });
  }
}
