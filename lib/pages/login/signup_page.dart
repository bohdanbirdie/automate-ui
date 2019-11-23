import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/store/auth/reducer.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:automate_ui/widgets/full_screen_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class _SignUpPageViewModel {
  final Function(String username, String password) onLogin;
  final NetworkState authNetwork;

  _SignUpPageViewModel({this.onLogin, this.authNetwork});
}

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService authService = new AuthService();
  final _formKey = GlobalKey<FormState>();
  String _username;
  String _password;

  void _validateSession() async {
    bool wasError = false;
    await Future.delayed(Duration(milliseconds: 100)).then((_) {
      try {
        Navigator.of(context).push(FullScreenLoading());
      } catch (e) {
        wasError = true;
      }
    });

    final bool isValid = await authService.validateSession();
    if (isValid) {
      if (!wasError) {
        Navigator.of(context).pop();
      }
      Navigator.pushReplacementNamed(context, '/tabs');
    } else {
      if (!wasError) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  initState() {
    super.initState();

    _validateSession();
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _SignUpPageViewModel>(
      converter: (store) {
        return _SignUpPageViewModel(
          onLogin: (String username, String password) =>
              store.dispatch(loginUserAction(username, password)),
          authNetwork: store.state.auth.network,
        );
      },
      builder: (context, viewModel) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Automate UI'),
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(child: buildForm(viewModel)),
            ));
      },
    );
  }

  Widget buildForm(_SignUpPageViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Login',
              style: TextStyle(fontSize: 30),
            ),
            Visibility(
              visible: viewModel.authNetwork.error,
              child: Container(child: Text(viewModel.authNetwork.errorMessage)),
            ),
            buildTextFormField(
              "Username",
              "Username is required",
              false,
              (val) => _username = val,
            ),
            buildTextFormField(
              "Password",
              "Password is required",
              true,
              (val) => _password = val,
            ),
            Visibility(
              visible: !viewModel.authNetwork.loading,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: RaisedButton(
                  onPressed: () {
                    final FormState form = _formKey.currentState;

                    if (form.validate()) {
                      form.save();

                      viewModel.onLogin(_username, _password);
                      // Navigator.of(context).pop();
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ),
            Visibility(
              visible: viewModel.authNetwork.loading,
              child: Text('Loading'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFormField(
    String title,
    String errorHint,
    bool obscure,
    Function(String val) onSaved,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        obscureText: obscure,
        decoration: InputDecoration(hintText: title),
        onSaved: onSaved,
        validator: (value) {
          if (value.isEmpty) {
            return errorHint;
          }

          return null;
        },
      ),
    );
  }
}
