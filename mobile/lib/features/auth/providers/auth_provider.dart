
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/auth_api.dart';

class AuthState {
  const AuthState({
    this.user,
    this.loading = false,
    this.error,
  });

  final User? user;
  final bool loading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? loading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _bootstrap();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool get _isActive => !_disposed;

  void _setStateSafely(AuthState nextState) {
    if (_isActive) {
      state = nextState;
    }
  }

  Future<void> _bootstrap() async {
    _setStateSafely(state.copyWith(
      loading: true,
      clearError: true,
    ));

    try {
      final user = await AuthApi.instance.me();

      _setStateSafely(
        AuthState(user: user),
      );
    } catch (_) {
      // A failed session restoration leaves the user unauthenticated.
      // Keep the original behavior of not exposing bootstrap errors.
      _setStateSafely(const AuthState());
    }
  }

  Future<String?> register(String phone, String name) async {
    _setStateSafely(state.copyWith(
      loading: true,
      clearError: true,
    ));

    try {
      final devOtp = await AuthApi.instance.register(
        phone: phone,
        name: name,
      );

      _setStateSafely(state.copyWith(loading: false));
      return devOtp;
    } catch (error) {
      _setStateSafely(state.copyWith(
        loading: false,
        error: _msg(error),
      ));
      return null;
    }
  }

  Future<bool> verifyOtp({
    required String phone,
    required String code,
    required String password,
    required String name,
  }) async {
    _setStateSafely(state.copyWith(
      loading: true,
      clearError: true,
    ));

    try {
      final user = await AuthApi.instance.verifyOtp(
        phone: phone,
        code: code,
        password: password,
        name: name,
      );

      _setStateSafely(
        AuthState(user: user),
      );

      return true;
    } catch (error) {
      _setStateSafely(state.copyWith(
        loading: false,
        error: _msg(error),
      ));

      return false;
    }
  }

  Future<bool> login(String phone, String password) async {
    _setStateSafely(state.copyWith(
      loading: true,
      clearError: true,
    ));

    try {
      final user = await AuthApi.instance.login(
        phone: phone,
        password: password,
      );

      _setStateSafely(
        AuthState(user: user),
      );

      return true;
    } catch (error) {
      _setStateSafely(state.copyWith(
        loading: false,
        error: _msg(error),
      ));

      return false;
    }
  }

  Future<void> logout() async {
    _setStateSafely(state.copyWith(
      loading: true,
      clearError: true,
    ));

    try {
      await AuthApi.instance.logout();

      _setStateSafely(
        const AuthState(),
      );
    } catch (error) {
      _setStateSafely(state.copyWith(
        loading: false,
        error: _msg(error),
      ));

      rethrow;
    }
  }

  String _msg(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }

    return 'خطای ناشناخته';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
