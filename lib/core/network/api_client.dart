import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../utils/token_manager.dart';

class ApiClient {
  final Dio dio;
  final TokenManager tokenManager;

  ApiClient({required this.tokenManager})
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          sendTimeout: ApiConstants.sendTimeout,
          headers: {
            ApiConstants.ngrokHeaderKey: ApiConstants.ngrokHeaderValue,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokenManager.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Log errors or handle global token refresh if needed
          return handler.next(error);
        },
      ),
    );
  }
}
