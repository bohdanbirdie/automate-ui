import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool loading;
  final String title;

  const LoadingOverlay({
    this.loading = false,
    this.title = 'Loading',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Visibility(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).splashColor.withOpacity(0.3),
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: Container(
                color: Theme.of(context).splashColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        visible: loading,
      ),
    );
  }
}
