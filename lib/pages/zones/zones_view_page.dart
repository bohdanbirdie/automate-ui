import 'package:automate_ui/store/root_reducer.dart';
import 'package:automate_ui/store/zones/reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class ZonesViewPage extends StatelessWidget {
  final String zoneUiId;
  ZonesViewPage(this.zoneUiId);

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(
      converter: (store) {
        return new _ViewModel(zone: store.state.zones.zones[zoneUiId]);
      },
      builder: (context, viewModel) {
        return Scaffold(
          appBar: AppBar(
            title: Text(viewModel.zone.identifier),
          ),
          body: Center(
            child: RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go back!'),
            ),
          ),
        );
      },
    );
  }
}

class _ViewModel {
  final Zone zone;

  _ViewModel({
    @required this.zone,
  });
}
