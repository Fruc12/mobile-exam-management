import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/secure_storage.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {
          'Accept': 'application/json',
        },

        /// 🔥 IMPORTANT
        /// On empêche Dio de throw automatiquement
        // validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['ngrok-skip-browser-warning'] = true;
          return handler.next(options);
        },
      ),
    );

    return dio;
  }
}
