import 'package:dio/dio.dart';

class ApiBase {
  final Dio _dio;

  ApiBase(this._dio);

  Future<Response> get(String url) async {
    try {
      final response = await _dio.get(url);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String url, dynamic data) async {
    try {
      final response = await _dio.post(url, data: data);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 可以添加其他HTTP方法的封装，如put、delete等

  dynamic _handleError(dynamic error) {
    // 处理错误逻辑，将错误信息包含在返回值中
    return {'error': error.toString()};
  }
}
