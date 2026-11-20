class EnvConfig {
  static const String appName = 'EduMind AI';
  static const String appVersion = '1.0.0';

  // Base API URL pointing to the FastAPI backend
  // For iOS Simulator: http://127.0.0.1:8000/api
  // For Android Emulator: http://10.0.2.2:8000/api
  // For Real Device: IP address on LAN, e.g. http://192.168.1.100:8000/api
  static const String defaultApiUrl = 'http://127.0.0.1:8000/api';

  static String apiUrl = defaultApiUrl;

  static bool isDemoMode = true; // Can be toggled or configured
}
