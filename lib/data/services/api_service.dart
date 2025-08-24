// lib/data/services/api_service.dart
import 'dart:async'; // Add this import for Completer
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../../core/constants/api_endpoints.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storageService;

  ApiService(this._storageService) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Remove or modify validateStatus to trigger error interceptor for 401
      validateStatus: (status) {
        return status != null && status >= 200 && status < 300;
      },
    ));

    // Add cache interceptor with fixed options
    final cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.forceCache,
      // Remove: hitCacheOnErrorExcept: [401, 403], // This line is removed
      maxStale: const Duration(days: 7),
    );
    _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    // Add auth interceptor
    _dio.interceptors.add(AuthInterceptor(_storageService, _dio));

    // Add logging interceptor (for debug)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Generic request methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
  try {
    debugPrint('🔵 GET Request: ${ApiEndpoints.baseUrl}$path');
    debugPrint('🔵 Query params: $queryParameters');

    final response = await _dio.get(path, queryParameters: queryParameters);

    debugPrint('✅ Response status: ${response.statusCode}');
    debugPrint('✅ Response data type: ${response.data.runtimeType}');
    if (response.data is Map) {
      debugPrint('✅ Response keys: ${(response.data as Map).keys.toList()}');
    }
    if (response.data is List) {
      debugPrint('✅ Response is array with ${(response.data as List).length} items');
    }

    return response;
  } on DioException catch (e) {
    debugPrint('❌ API Error: ${e.message}');
    debugPrint('❌ Error response: ${e.response?.data}');
    throw _handleError(e);
  }
}

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // File upload
  Future<Response> uploadFile(String path, String filePath, {Map<String, dynamic>? data}) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        'file': await MultipartFile.fromFile(filePath),
      });
      return await _dio.post(path, data: formData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Download file
  Future<void> downloadFile(String url, String savePath, {Function(int, int)? onReceiveProgress}) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException error) {
    String message = 'An error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        if (statusCode == 401) {
          message = 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          message = 'Access forbidden.';
        } else if (statusCode == 404) {
          message = 'Resource not found.';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        } else if (responseData != null) {
          if (responseData is Map && responseData.containsKey('error')) {
            message = responseData['error'];
          } else if (responseData is Map && responseData.containsKey('message')) {
            message = responseData['message'];
          } else if (responseData is Map && responseData.containsKey('detail')) {
            message = responseData['detail'];
          } else {
            message = 'Error: ${error.response?.statusMessage ?? 'Unknown error'}';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
        break;
      default:
        message = error.message ?? 'An unexpected error occurred.';
    }

    return ApiException(message, statusCode: error.response?.statusCode);
  }
}

// Auth Interceptor
class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final Dio _dio;
  bool _isRefreshing = false;
  final _refreshCompleter = <RequestOptions, Completer<Response>>{};

  AuthInterceptor(this._storageService, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth header for refresh token endpoint
    if (options.path.contains('/refresh')) {
      handler.next(options);
      return;
    }

    final token = await _storageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('🔴 API Error: ${err.response?.statusCode} on ${err.requestOptions.path}');

    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/refresh') &&
        !err.requestOptions.path.contains('/login') &&
        !err.requestOptions.path.contains('/register')) {
      // If already refreshing, wait for it to complete
      if (_isRefreshing) {
        final completer = Completer<Response>();
        _refreshCompleter[err.requestOptions] = completer;

        try {
          final response = await completer.future;
          return handler.resolve(response);
        } catch (e) {
          return handler.reject(err);
        }
      }

      _isRefreshing = true;
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken != null) {
        try {
          debugPrint('🔄 Attempting to refresh token...');

          // Create a new Dio instance without interceptors to avoid infinite loop
          final refreshDio = Dio(BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ));

          final response = await refreshDio.post(
            ApiEndpoints.refreshToken,
            data: {'refresh': refreshToken},
          );

          final newAccessToken = response.data['access'];
          final newRefreshToken = response.data['refresh'] ?? refreshToken;

          await _storageService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          debugPrint('✅ Token refreshed successfully');

          // Retry all pending requests
          for (final entry in _refreshCompleter.entries) {
            try {
              entry.key.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await _dio.fetch(entry.key);
              entry.value.complete(retryResponse);
            } catch (e) {
              entry.value.completeError(e);
            }
          }
          _refreshCompleter.clear();

          // Retry the original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final clonedRequest = await _dio.fetch(err.requestOptions);
          _isRefreshing = false;
          return handler.resolve(clonedRequest);

        } catch (e) {
          debugPrint('❌ Token refresh failed: $e');
          _isRefreshing = false;
          _refreshCompleter.clear();

          // Clear tokens and redirect to login
          await _storageService.clearTokens();
          await _storageService.clearUser();
        }
      }
      _isRefreshing = false;
    }
    handler.next(err);
  }
}

// Custom Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}


