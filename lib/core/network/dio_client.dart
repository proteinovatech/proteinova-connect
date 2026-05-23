import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:proteinova_connect/core/config/api_config.dart';

class DioClient {
  final Dio dio;

  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 40),
          receiveTimeout: const Duration(seconds: 40),
          headers: {"Content-Type": "application/json"},
        ),
      ) {
    _addInterceptor();
  }

  void _addInterceptor() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint("REQUEST: ${options.method} ${options.uri}");
          debugPrint("BODY: ${options.data}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint("RESPONSE: ${response.statusCode}");
          debugPrint("DATA: ${response.data}");
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint("ERROR: ${error.response?.statusCode}");
          debugPrint("ERROR DATA: ${error.response?.data}");
          debugPrint("MESSAGE: ${error.message}");
          return handler.next(error);
        },
      ),
    );
  }
}
