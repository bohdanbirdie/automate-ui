import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Sorry, no items found",
              style: TextStyle(fontSize: 24),
            ),
            Text(
              "Try adding one",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
