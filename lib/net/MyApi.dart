import 'dart:async';

import 'package:dio/dio.dart';
import 'ApiBase.dart';

class MyApi extends ApiBase {
  MyApi(Dio dio) : super(dio);

  Future<Response> testSDConnection(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}app_id';
    }else{
      url = '$url/app_id';
    }
    return get(url);
  }

  Future<Response> getSDLoras(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/loras';
    }else{
      url = '$url/sdapi/v1/loras';
    }
    return get(url);
  }

  Future<Response> getSDModels(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/sd-models';
    }else{
      url = '$url/sdapi/v1/sd-models';
    }
    return get(url);
  }

  Future<Response> getSDVaes(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/sd-vae';
    }else{
      url = '$url/sdapi/v1/sd-vae';
    }
    return get(url);
  }

  Future<Response> getSDSamplers(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/samplers';
    }else{
      url = '$url/sdapi/v1/samplers';
    }
    return get(url);
  }
}
