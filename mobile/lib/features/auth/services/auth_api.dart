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
    final r = await _dio.post(
      ApiConfig.register,
      data: {'phone': phone, 'name': name},
    );
    return r.data['dev_otp'] as String?;
  }

  Future<User> verifyOtp({
    required String phone,
    required String code,
    required String password,
    required String name,
  }) async {
    final r = await _dio.post(
      ApiConfig.verifyOtp,
      data: {
        'phone': phone,
        'code': code,
        'password': password,
        'name': name,
      },
    );
    await SecureStorage.saveTokens(
      accessToken: r.data['access_token'] as String,
      refreshToken: r.data['refresh_token'] as String,
    );
    return me();
  }

  Future<User> login({
    required String phone,
    required String password,
  }) async {
    // ignore: avoid_print
    print('=== AUTH_API: POST ${ApiConfig.baseUrl}${ApiConfig.login} ===');
    try {
      final r = await _dio.post(
        ApiConfig.login,
        data: {'phone': phone, 'password': password},
      );
      // ignore: avoid_print
      print('=== AUTH_API: OK ${r.statusCode} ===');
      await SecureStorage.saveTokens(
        accessToken: r.data['access_token'] as String,
        refreshToken: r.data['refresh_token'] as String,
      );
      return me();
    } catch (e) {
      // ignore: avoid_print
      print('=== AUTH_API: FAIL $e ===');
      rethrow;
    }
  }

  Future<User> me() async {
    final r = await _dio.get(ApiConfig.me);
    return User.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await SecureStorage.clear();
  }
}