class ApiConstants {
  static const String baseUrl =
      'https://degraded-system-overpower.ngrok-free.dev/api/';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String ngrokHeaderKey = 'ngrok-skip-browser-warning';
  static const String ngrokHeaderValue = 'true';

  // Endpoints
  static const String login = 'auth/login';
  static const String dashboard = 'dashboard';
  static const String serverMetrics = 'metrics/servers';
  static const String servers = 'servers';
  static const String projects = 'projects';
  static const String alerts = 'alerts';
  static const String logs = 'logs';
  static const String users = 'users';
}
