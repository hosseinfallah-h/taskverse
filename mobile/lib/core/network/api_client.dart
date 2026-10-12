import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage.dart';
import 'api_config.dart';

/// Single Dio instance with JWT injection + auto refresh on 401.
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
        // Allow all status codes for debugging
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (o) => debugPrint('[DIO] $o'),
      ));
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.accessToken;
          if (kDebugMode) {
            debugPrint('=== INTERCEPTOR: ${options.method} ${options.uri} hasToken=${token != null} ===');
          }
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            debugPrint('=== INTERCEPTOR ERROR: ${error.type} ${error.message} ===');
          }
          if (error.response?.statusCode == 401 &&
              error.requestOptions.path != ApiConfig.refresh) {
            final refreshed = await _tryRefresh();
            if (refreshed) {
              final token = await SecureStorage.accessToken;
              final req = error.requestOptions;
              req.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(req);
                return handler.resolve(response);
              } catch (_) {}
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();
  late final Dio _dio;

  Dio get dio => _dio;

  Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await SecureStorage.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)).post(
        ApiConfig.refresh,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final access = data['access_token'] as String?;
      final refresh = data['refresh_token'] as String?;
      if (access == null || refresh == null) return false;

      await SecureStorage.saveTokens(
        accessToken: access,
        refreshToken: refresh,
      );
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Refresh failed: $e');
      await SecureStorage.clear();
      return false;
    }
  }
}