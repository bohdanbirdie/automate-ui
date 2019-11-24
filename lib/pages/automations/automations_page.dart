import 'package:automate_ui/pages/automations/view_automation.dart';
import 'package:automate_ui/store/automations/automation_model.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:automate_ui/widgets/empty_state.dart';
import 'package:automate_ui/widgets/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class AutomationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(converter: (store) {
      return new _ViewModel.fromStore(store);
    }, builder: (context, viewModel) {
      if (viewModel.loading) {
        return LoadingState();
      }

      if (viewModel.automations.length == 0) {
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
            itemCount: viewModel.automations.length,
            itemBuilder: (context, index) {
              final Automation item = viewModel.automations[index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ViewAutomationPage(automationId: item.id)),
                  );
                },
                title: Text(item.name),
                subtitle: Text(item.description),
                trailing: Icon(Icons.keyboard_arrow_right),
              );
            }),
      );
    });
  }
}

class _ViewModel {
  final List<Automation> automations;
  final bool loading;

  _ViewModel._({
    @required this.automations,
    @required this.loading,
  });

  factory _ViewModel.fromStore(Store<AppState> store) {
    return _ViewModel._(
      automations: List.from(store.state.automations.automations.values),
      loading: store.state.automations.network.loading,
    );
  }
}
