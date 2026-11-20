import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../storage/storage_service.dart';

class ApiClient {
  final Dio _dio;
  final StorageService _storageService;

  ApiClient({required StorageService storageService})
    : _storageService = storageService,
      _dio = Dio(
        BaseOptions(
          baseUrl: EnvConfig.apiUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Log without sensitive tokens
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
