import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/store/auth/reducer.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class _LoginPageViewModel {
  final Function(String username, String password) onLogin;
  final NetworkState authNetwork;

  _LoginPageViewModel({this.onLogin, this.authNetwork});
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService = new AuthService();
  final _formKey = GlobalKey<FormState>();
  String _username;
  String _password;

  void _validateSession() async {
    bool isValid = await authService.validateSession();
    if (isValid) {
      Future.delayed(Duration(milliseconds: 100)).then((_) {
        Navigator.pushReplacementNamed(context, '/tabs');
      });
    }
  }

  @override
  initState() {
    super.initState();

    _validateSession();
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _LoginPageViewModel>(
      converter: (store) {
        return _LoginPageViewModel(
            onLogin: (String username, String password) =>
                loginUserAction(store, username, password),
            authNetwork: store.state.auth.network);
      },
      builder: (context, viewModel) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Login page'),
            ),
            body: Center(
                child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: viewModel.authNetwork.error
                          ? Text(viewModel.authNetwork.errorMessage)
                          : null),
                  TextFormField(
                    decoration: InputDecoration(hintText: "Username"),
                    onSaved: (val) => _username = val,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Username is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(hintText: "Password"),
                    onSaved: (val) => _password = val,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: viewModel.authNetwork.loading
                          ? null
                          : () {
                              final FormState form = _formKey.currentState;

                              if (form.validate()) {
                                form.save();

                                viewModel.onLogin(_username, _password);
                              }
                            },
                      child: viewModel.authNetwork.loading
                          ? Text('Loading')
                          : Text('Submit'),
                    ),
                  ),
                ],
              ),
            )));
      },
    );
  }
}
