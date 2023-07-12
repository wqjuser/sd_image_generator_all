import 'dart:async';

import 'package:dio/dio.dart';
import 'ApiBase.dart';

class MyApi extends ApiBase {
  MyApi(Dio dio) : super(dio);

  Future<Response> testSDConnection(String sdUrl) {
    var url = sdUrl;
    return get(url);
  }
}
