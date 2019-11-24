import 'package:automate_ui/store/events/event_model.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:automate_ui/widgets/empty_state.dart';
import 'package:automate_ui/widgets/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class EventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(converter: (store) {
      return new _ViewModel.fromStore(store);
    }, builder: (context, viewModel) {
      if (viewModel.loading) {
        return LoadingState();
      }

      if (viewModel.events.length == 0) {
        return EmptyState();
      }

      return Container(
        color: Theme.of(context).cardColor,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
            separatorBuilder: (context, index) => Divider(
                  color: Colors.black,
                ),
            itemCount: viewModel.events.length,
            itemBuilder: (context, index) {
              final Event item = viewModel.events[index];
              return ListTile(
                title: Text(item.name),
                trailing: Icon(Icons.keyboard_arrow_right),
              );
            }),
      );
    });
  }
}

class _ViewModel {
  final List<Event> events;
  final bool loading;

  _ViewModel._({
    @required this.events,
    @required this.loading,
  });

  factory _ViewModel.fromStore(Store<AppState> store) {
    return _ViewModel._(
      events: List.from(store.state.events.events.values),
      loading: store.state.events.network.loading,
    );
  }
}
