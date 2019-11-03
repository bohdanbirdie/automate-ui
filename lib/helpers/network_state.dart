import 'package:flutter/material.dart';

class NetworkState {
  final bool loading;
  final bool error;
  final String errorMessage;

  const NetworkState({ this.loading = false, this.error = false, this.errorMessage = ''});

  NetworkState.request({ this.loading = true, this.error = false, this.errorMessage = ''});
  NetworkState.success({ this.loading = false, this.error = false, this.errorMessage = ''});
  NetworkState.failure({ this.loading = false, this.error = true, @required this.errorMessage });
}