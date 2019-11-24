import 'package:automate_ui/store/root_reducer.dart';
import 'package:automate_ui/store/zones/zone_model.dart';
import 'package:automate_ui/widgets/subtitle_text.dart';
import 'package:automate_ui/widgets/title_text.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
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
          appBar: AppBar(title: Icon(Icons.map)),
          body: Builder(
            builder: (context) => Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TitleText(text: 'Zone name'),
                    SubtitleText(text: viewModel.zone.identifier),
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: TitleText(text: 'Location'),
                    ),
                    buildLocationRow(
                        context, viewModel.zone.latitude, 'Latitude'),
                    buildLocationRow(
                        context, viewModel.zone.longitude, 'Longtitude'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildLocationRow(BuildContext context, double param, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SubtitleText(
            text: '$title: ${param.toStringAsFixed(7)}',
          ),
          RaisedButton(
            onPressed: () {
              _copyToClipboard(
                context,
                param.toString(),
              );
            },
            child: Container(child: Text('Copy')),
          )
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String content) {
    ClipboardManager.copyToClipBoard(content).then((result) {
      final snackBar = SnackBar(
        content: Text('Location Copied to Clipboard'),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {},
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }
}

class _ViewModel {
  final ZoneModel zone;

  _ViewModel({
    @required this.zone,
  });
}
