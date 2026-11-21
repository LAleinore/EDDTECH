import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  }) : _secureStorage = secureStorage,
       _prefs = prefs;

  SharedPreferences get prefs => _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'cached_user_json';
  static const String _langKey = 'user_language';
  static const String _isDarkKey = 'is_dark_theme';
  static const String _fontScaleKey = 'font_scale';
  static const String _highContrastKey = 'high_contrast';
  static const String _reduceMotionKey = 'reduce_motion';
  static const String _demoModeKey = 'demo_mode_active';

  // Secure Token
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // Cached User JSON
  Future<void> saveUserJson(String jsonStr) async {
    await _prefs.setString(_userKey, jsonStr);
  }

  String? getUserJson() {
    return _prefs.getString(_userKey);
  }

  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }

  // Preferences
  String getLanguageCode() {
    return _prefs.getString(_langKey) ?? 'ru';
  }

  Future<void> setLanguageCode(String code) async {
    await _prefs.setString(_langKey, code);
  }

  bool isDarkTheme() {
    return _prefs.getBool(_isDarkKey) ?? false;
  }

  Future<void> setDarkTheme(bool value) async {
    await _prefs.setBool(_isDarkKey, value);
  }

  double getFontScale() {
    return _prefs.getDouble(_fontScaleKey) ?? 1.0;
  }

  Future<void> setFontScale(double scale) async {
    await _prefs.setDouble(_fontScaleKey, scale);
  }

  bool isHighContrast() {
    return _prefs.getBool(_highContrastKey) ?? false;
  }

  Future<void> setHighContrast(bool value) async {
    await _prefs.setBool(_highContrastKey, value);
  }

  bool isReduceMotion() {
    return _prefs.getBool(_reduceMotionKey) ?? false;
  }

  Future<void> setReduceMotion(bool value) async {
    await _prefs.setBool(_reduceMotionKey, value);
  }

  bool isDemoMode() {
    return _prefs.getBool(_demoModeKey) ?? true;
  }

  Future<void> setDemoMode(bool value) async {
    await _prefs.setBool(_demoModeKey, value);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
