import 'package:automate_ui/helpers/network_state.dart';
import 'package:automate_ui/services/auth_service.dart';
import 'package:automate_ui/store/auth/reducer.dart';
import 'package:automate_ui/store/root_reducer.dart';
import 'package:automate_ui/widgets/full_screen_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class _LoginPageViewModel {
  final Function(String username, String password, bool isRegistration) onLogin;
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
  bool _isRegistration = false;

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
    return new StoreConnector<AppState, _LoginPageViewModel>(
      converter: (store) {
        return _LoginPageViewModel(
          onLogin: (String username, String password, bool isRegistration) =>
              store.dispatch(
                  loginUserAction(username, password, isRegistration)),
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

  Widget buildForm(_LoginPageViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildAnimatedDefaultTextStyle('Login', !_isRegistration),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Switch(
                    value: _isRegistration,
                    onChanged: (val) {
                      setState(() {
                        _isRegistration = val;
                      });
                    },
                  ),
                ),
                buildAnimatedDefaultTextStyle('Signup', _isRegistration),
              ],
            ),
            Visibility(
              visible: viewModel.authNetwork.error,
              child: Container(
                child: Text(
                  viewModel.authNetwork.errorMessage,
                  style: TextStyle(
                    color: Theme.of(context).errorColor,
                    fontSize: 17,
                  ),
                ),
              ),
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

                      viewModel.onLogin(_username, _password, _isRegistration);
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

  Widget buildAnimatedDefaultTextStyle(String text, isActive) {
    return AnimatedDefaultTextStyle(
      style: isActive
          ? TextStyle(fontSize: 30, color: Colors.black)
          : TextStyle(fontSize: 30.0, color: Colors.black.withOpacity(0.5)),
      duration: const Duration(milliseconds: 200),
      child: Text(text),
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
