// lib/data/services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  // Token Management - Use SharedPreferences for web
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      await _prefs.setString(_accessTokenKey, accessToken);
      await _prefs.setString(_refreshTokenKey, refreshToken);
    } else {
      // Use secure storage for mobile
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() async {
    if (kIsWeb) {
      return _prefs.getString(_accessTokenKey);
    } else {
      return await _secureStorage.read(key: _accessTokenKey);
    }
  }

  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      return _prefs.getString(_refreshTokenKey);
    } else {
      return await _secureStorage.read(key: _refreshTokenKey);
    }
  }

  Future<void> clearTokens() async {
    if (kIsWeb) {
      await _prefs.remove(_accessTokenKey);
      await _prefs.remove(_refreshTokenKey);
    } else {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    }
  }

  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // User Data - Use SharedPreferences for web
  Future<void> saveUser(Map<String, dynamic> user) async {
    final userString = jsonEncode(user);
    if (kIsWeb) {
      await _prefs.setString(_userKey, userString);
    } else {
      await _secureStorage.write(key: _userKey, value: userString);
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    String? userString;
    if (kIsWeb) {
      userString = _prefs.getString(_userKey);
    } else {
      userString = await _secureStorage.read(key: _userKey);
    }

    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  Future<void> clearUser() async {
    if (kIsWeb) {
      await _prefs.remove(_userKey);
    } else {
      await _secureStorage.delete(key: _userKey);
    }
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
    if (!kIsWeb) {
      await _secureStorage.deleteAll();
    }
    await _prefs.clear();
  }
}