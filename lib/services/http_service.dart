import 'package:automate_ui/store/root_reducer.dart';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';

class HttpService extends http.BaseClient{
  static final HttpService _singleton = HttpService._internal();

  factory HttpService() {
    return _singleton;
  }

  HttpService._internal();

  http.Client _httpClient = new http.Client();
  
  static Store<AppState> store;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (HttpService.store != null) {
      print('Store passed');
      request.headers.addAll({ 'Authorization': HttpService.store.state.auth.userToken});
    }
    return _httpClient.send(request);
  }
}
