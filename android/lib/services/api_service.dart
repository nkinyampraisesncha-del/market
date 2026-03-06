import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(_handleError(error));
        },
      ),
    );
  }

  DioException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return DioException(
          requestOptions: error.requestOptions,
          message: 'Connection timed out. Please try again.',
          type: error.type,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String message;
        if (statusCode == 401) {
          message = 'Unauthorized. Please log in again.';
        } else if (statusCode == 403) {
          message = 'You do not have permission to perform this action.';
        } else if (statusCode == 404) {
          message = 'The requested resource was not found.';
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Server error. Please try again later.';
        } else {
          message = error.message ?? 'An error occurred.';
        }
        return DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          message: message,
          type: error.type,
        );
      default:
        return DioException(
          requestOptions: error.requestOptions,
          message: 'Network error. Check your connection.',
          type: error.type,
        );
    }
  }

  Future<Response<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(url,
        queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String url, {
    dynamic data,
    Options? options,
  }) {
    return _dio.post<T>(url, data: data, options: options);
  }

  Future<Response<T>> put<T>(
    String url, {
    dynamic data,
    Options? options,
  }) {
    return _dio.put<T>(url, data: data, options: options);
  }

  Future<Response<T>> delete<T>(
    String url, {
    dynamic data,
    Options? options,
  }) {
    return _dio.delete<T>(url, data: data, options: options);
  }
}
