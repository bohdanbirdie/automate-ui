import 'package:automate_ui/helpers/constants.dart';
import 'package:dio/dio.dart';

BaseOptions _options = new BaseOptions(
    baseUrl: hostname,
);

Dio httpService = new Dio(_options);

