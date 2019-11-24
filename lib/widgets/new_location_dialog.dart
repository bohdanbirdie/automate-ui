import 'package:flutter/material.dart';

class NewLocationDialog extends StatefulWidget {
  final double radius;
  final ValueChanged<double> onChangeEnd;
  final VoidCallback onBackgropClick;
  final ValueChanged<_SaveData> onSave;

  NewLocationDialog({
    @required this.radius,
    @required this.onChangeEnd,
    @required this.onSave,
    @required this.onBackgropClick,
  });

  @override
  _NewLocationDialogState createState() => _NewLocationDialogState();
}

class _NewLocationDialogState extends State<NewLocationDialog> {
  double _instantRadiusValue;
  final _formKey = GlobalKey<FormState>();
  String _zoneName;

  @override
  initState() {
    super.initState();

    _instantRadiusValue = widget.radius;
  }

  void _showMaterialDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Discard marker?'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              FlatButton(
                onPressed: () {
                  widget.onBackgropClick();
                  Navigator.pop(context);
                },
                child: Text('Discard'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          _showMaterialDialog();
        },
        child: Container(
            alignment: Alignment.bottomCenter,
            color: Colors.white10.withOpacity(0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.80,
              height: 100,
              decoration: new BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(5.0, 5.0),
                  )
                ],
                borderRadius: new BorderRadius.circular(15.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Slider(
                                activeColor: Colors.indigoAccent,
                                min: 0.1,
                                max: 1,
                                divisions: 9,
                                onChangeEnd: (newRating) {
                                  widget.onChangeEnd(newRating * 1000);
                                },
                                onChanged: (newRating) {
                                  setState(() =>
                                      _instantRadiusValue = newRating * 1000);
                                },
                                value: _instantRadiusValue / 1000,
                              ),
                              Padding(
                                child: Text(
                                  _instantRadiusValue.toInt().toString() + 'm',
                                  style: TextStyle(
                                    color: Colors.indigoAccent,
                                  ),
                                ),
                                padding: EdgeInsets.only(right: 5),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                child: Form(
                                  key: _formKey,
                                  child: TextFormField(
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(height: 0),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.indigoAccent)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.indigoAccent)),
                                      focusedErrorBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.red)),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 5),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _zoneName = val;
                                      });
                                    },
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                      width: 65,
                      child: ClipRRect(
                          borderRadius: new BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          child: RaisedButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              final FormState form = _formKey.currentState;
                              if (form.validate()) {
                                form.save();

                                // viewModel.onLogin(_username, _password);
                                widget.onSave(_SaveData(
                                    radius: _instantRadiusValue,
                                    zoneName: _zoneName));
                              }
                            },
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration:
                                  new BoxDecoration(color: Colors.indigoAccent),
                              child: Icon(
                                Icons.done_outline,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ),
                          ))),
                ],
              ),
            )),
      ),
    );
  }
}

class _SaveData {
  final double radius;
  final String zoneName;

  _SaveData({
    @required this.radius,
    @required this.zoneName,
  });
}
