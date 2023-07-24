import 'dart:async';

import 'package:dio/dio.dart';
import 'ApiBase.dart';

class MyApi extends ApiBase {
  MyApi(Dio dio) : super(dio);

  Future<Response> testSDConnection(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}app_id';
    } else {
      url = '$url/app_id';
    }
    return get(url);
  }

  Future<Response> getSDLoras(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/loras';
    } else {
      url = '$url/sdapi/v1/loras';
    }
    return get(url);
  }

  Future<Response> getSDModels(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/sd-models';
    } else {
      url = '$url/sdapi/v1/sd-models';
    }
    return get(url);
  }

  Future<Response> getSDVaes(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/sd-vae';
    } else {
      url = '$url/sdapi/v1/sd-vae';
    }
    return get(url);
  }

  Future<Response> getSDSamplers(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/samplers';
    } else {
      url = '$url/sdapi/v1/samplers';
    }
    return get(url);
  }
  // 获取高清修复算法
  Future<Response> getSDUpscalers(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/upscalers';
    } else {
      url = '$url/sdapi/v1/upscalers';
    }
    return get(url);
  }
  // 获取高清修复latent-upscale算法
  Future<Response> getSDlLatentUpscaleModes(String sdUrl) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/latent-upscale-modes';
    } else {
      url = '$url/sdapi/v1/latent-upscale-modes';
    }
    return get(url);
  }
  // 图生图接口
  Future<Response> sdText2Image(
      String sdUrl, Map<String, dynamic> requestBody) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/txt2img';
    } else {
      url = '$url/sdapi/v1/txt2img';
    }
    return post(url, requestBody);
  }
}
