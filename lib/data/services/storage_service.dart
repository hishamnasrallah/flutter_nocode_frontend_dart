// lib/data/services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static late SharedPreferences _prefs;

  // Keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';
  static const String _themeKey = 'theme';
  static const String _languageKey = 'language';
  static const String _firstTimeKey = 'first_time';

  // Initialize
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management (Secure Storage)
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  // User Data (Secure Storage)
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _secureStorage.write(key: _userKey, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userString = await _secureStorage.read(key: _userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  Future<void> clearUser() async {
    await _secureStorage.delete(key: _userKey);
  }

  // App Preferences (Shared Preferences)
  Future<void> setTheme(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  String getTheme() {
    return _prefs.getString(_themeKey) ?? 'light';
  }

  Future<void> setLanguage(String language) async {
    await _prefs.setString(_languageKey, language);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> setFirstTime(bool firstTime) async {
    await _prefs.setBool(_firstTimeKey, firstTime);
  }

  bool isFirstTime() {
    return _prefs.getBool(_firstTimeKey) ?? true;
  }

  // Recent Projects (Shared Preferences)
  Future<void> saveRecentProjects(List<Map<String, dynamic>> projects) async {
    await _prefs.setString('recent_projects', jsonEncode(projects));
  }

  List<Map<String, dynamic>> getRecentProjects() {
    final projectsString = _prefs.getString('recent_projects');
    if (projectsString != null) {
      final decoded = jsonDecode(projectsString);
      return List<Map<String, dynamic>>.from(decoded);
    }
    return [];
  }

  // Cache Management
  Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (String key in keys) {
      if (!key.contains(_themeKey) && !key.contains(_languageKey)) {
        await _prefs.remove(key);
      }
    }
  }

  // Clear All Data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
