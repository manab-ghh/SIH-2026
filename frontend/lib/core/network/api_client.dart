import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

class ApiClient {
  late final Dio dio;
  final StorageService _storageService = StorageService();

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('[Dio Request] ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
                '[Dio Response] ${response.statusCode} from ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('[Dio Error] ${e.response?.statusCode}: ${e.message}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Helper method for extracting friendly error messages
  static String formatError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data is Map) {
        final msg = error.response?.data['message'];
        if (msg != null && msg.toString().isNotEmpty) {
          return msg.toString();
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your network and try again.';
        case DioExceptionType.connectionError:
          return 'Cannot connect to server. Please ensure the backend is running.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    return error?.toString() ?? 'An unexpected error occurred.';
  }
}
