import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class EnvConfig {
  static const String appName = 'EduMind AI';
  static const String appVersion = '1.0.0';

  // Base API URL pointing to the FastAPI backend
  // For iOS Simulator: http://127.0.0.1:8000/api
  // For Android Emulator: http://10.0.2.2:8000/api
  // For Real Device: IP address on LAN, e.g. http://192.168.1.100:8000/api
  static String get defaultApiUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000/api';
  }

  static String apiUrl = defaultApiUrl;

  static bool isDemoMode = false; // Connected to live backend
}
