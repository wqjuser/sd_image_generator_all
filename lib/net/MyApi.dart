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

  // 获取采样算法
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

  // 文生图接口
  Future<Response> sdText2Image(String sdUrl, Map<String, dynamic> requestBody) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/txt2img';
    } else {
      url = '$url/sdapi/v1/txt2img';
    }
    return post(url, requestBody);
  }

  // 图生图接口
  Future<Response> sdImage2Image(String sdUrl, Map<String, dynamic> requestBody) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/img2img';
    } else {
      url = '$url/sdapi/v1/img2img';
    }
    return post(url, requestBody);
  }

  // SD设置参数，一般用来修改模型
  Future<Response> sdOptions(String sdUrl, Map<String, dynamic> requestBody) {
    var url = sdUrl;
    if (url.endsWith('/')) {
      url = '${url}sdapi/v1/options';
    } else {
      url = '$url/sdapi/v1/options';
    }
    return post(url, requestBody);
  }

  // 用于测试gpt接口是否可用
  Future<Response> testChatGPT(String apiKey) {
    var url = "https://youraihelper.xyz/v1/chat/completions";
    Options options = Options(headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    });
    Map<String, dynamic> requestBody = {
      "model": "gpt-3.5-turbo-0613",
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "你好"}
      ]
    };
    return post(url, requestBody, options);
  }
}
