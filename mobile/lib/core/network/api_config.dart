/// API configuration.
///
/// For development on a real device over USB:
///   - Android emulator uses 10.0.2.2
///   - Physical device uses your PC's LAN IP (e.g. 192.168.1.42)
///   - Or use `adb reverse tcp:8000 tcp:8000` and keep 127.0.0.1
///
/// We use adb reverse in dev so 127.0.0.1 works on the phone.
class ApiConfig {
  ApiConfig._();

  /// Change to your VPS URL for production later.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Endpoints
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';

  static const String tasks = '/tasks';
  static const String projects = '/projects';
  static const String tags = '/tags';
  static const String people = '/people';
}