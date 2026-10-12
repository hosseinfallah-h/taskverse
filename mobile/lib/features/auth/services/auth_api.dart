import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user.dart';

class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();

  Dio get _dio => ApiClient.instance.dio;

  /// Returns the dev OTP (only in DEBUG builds with SMS disabled).
  Future<String?> register({
    required String phone,
    required String name,
  }) async {
    final url = '${ApiConfig.baseUrl}${ApiConfig.register}';
    if (kDebugMode) debugPrint('=== AUTH_API: POST $url ===');
    try {
      final r = await _dio.post(
        ApiConfig.register,
        data: {'phone': phone, 'name': name},
      );
      if (kDebugMode) {
        debugPrint('=== AUTH_API: register OK ${r.statusCode} ===');
      }
      return r.data['dev_otp'] as String?;
    } catch (e) {
      if (kDebugMode) debugPrint('=== AUTH_API: register FAIL: $e ===');
      rethrow;
    }
  }

  Future<User> verifyOtp({
    required String phone,
    required String code,
    required String password,
    required String name,
  }) async {
    final url = '${ApiConfig.baseUrl}${ApiConfig.verifyOtp}';
    if (kDebugMode) debugPrint('=== AUTH_API: POST $url ===');
    try {
      final r = await _dio.post(
        ApiConfig.verifyOtp,
        data: {
          'phone': phone,
          'code': code,
          'password': password,
          'name': name,
        },
      );
      if (kDebugMode) {
        debugPrint('=== AUTH_API: verifyOtp OK ${r.statusCode} ===');
      }
      await SecureStorage.saveTokens(
        accessToken: r.data['access_token'] as String,
        refreshToken: r.data['refresh_token'] as String,
      );
      return me();
    } catch (e) {
      if (kDebugMode) debugPrint('=== AUTH_API: verifyOtp FAIL: $e ===');
      rethrow;
    }
  }

  Future<User> login({
    required String phone,
    required String password,
  }) async {
    final url = '${ApiConfig.baseUrl}${ApiConfig.login}';
    if (kDebugMode) {
      debugPrint('=== AUTH_API: POST $url ===');
      debugPrint('=== AUTH_API: body phone=$phone passLen=${password.length} ===');
    }
    try {
      final r = await _dio.post(
        ApiConfig.login,
        data: {'phone': phone, 'password': password},
      );
      if (kDebugMode) {
        debugPrint('=== AUTH_API: login OK ${r.statusCode} ===');
      }
      await SecureStorage.saveTokens(
        accessToken: r.data['access_token'] as String,
        refreshToken: r.data['refresh_token'] as String,
      );
      return me();
    } catch (e) {
      if (kDebugMode) debugPrint('=== AUTH_API: login FAIL: $e ===');
      rethrow;
    }
  }

  Future<User> me() async {
    if (kDebugMode) debugPrint('=== AUTH_API: GET ${ApiConfig.me} ===');
    try {
      final r = await _dio.get(ApiConfig.me);
      if (kDebugMode) debugPrint('=== AUTH_API: me OK ${r.statusCode} ===');
      return User.fromJson(r.data as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('=== AUTH_API: me FAIL: $e ===');
      rethrow;
    }
  }

  Future<void> logout() async {
    await SecureStorage.clear();
  }
}