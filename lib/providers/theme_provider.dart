// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import '../data/models/theme.dart';
import '../data/services/api_service.dart';
import '../core/constants/api_endpoints.dart';

class ThemeProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<AppTheme> _themes = [];
  List<Map<String, dynamic>> _themeTemplates = [];
  AppTheme? _selectedTheme;
  bool _isLoading = false;
  String? _error;

  List<AppTheme> get themes => _themes;
  List<Map<String, dynamic>> get themeTemplates => _themeTemplates;
  AppTheme? get selectedTheme => _selectedTheme;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ThemeProvider(this._apiService);

  Future<void> fetchThemes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiEndpoints.themes);
      final List<dynamic> data = response.data['results'] ?? response.data;
      _themes = data.map((json) => AppTheme.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchThemeTemplates() async {
    try {
      final response = await _apiService.get(ApiEndpoints.themeTemplates);
      _themeTemplates = List<Map<String, dynamic>>.from(response.data);
      notifyListeners();
    } catch (e) {
      // Templates are optional
    }
  }

  Future<void> fetchThemeDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiEndpoints.themeDetail(id));
      _selectedTheme = AppTheme.fromJson(response.data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppTheme?> createTheme({
    required String name,
    required String primaryColor,
    required String accentColor,
    required String backgroundColor,
    required String textColor,
    String fontFamily = 'Roboto',
    bool isDarkMode = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiEndpoints.themes,
        data: {
          'name': name,
          'primary_color': primaryColor,
          'accent_color': accentColor,
          'background_color': backgroundColor,
          'text_color': textColor,
          'font_family': fontFamily,
          'is_dark_mode': isDarkMode,
        },
      );

      final theme = AppTheme.fromJson(response.data);
      _themes.insert(0, theme);

      _isLoading = false;
      notifyListeners();
      return theme;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateTheme(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.patch(
        ApiEndpoints.themeDetail(id),
        data: data,
      );

      final updatedTheme = AppTheme.fromJson(response.data);
      final index = _themes.indexWhere((theme) => theme.id.toString() == id);
      if (index != -1) {
        _themes[index] = updatedTheme;
      }
      if (_selectedTheme?.id.toString() == id) {
        _selectedTheme = updatedTheme;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTheme(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.delete(ApiEndpoints.themeDetail(id));
      _themes.removeWhere((theme) => theme.id.toString() == id);
      if (_selectedTheme?.id.toString() == id) {
        _selectedTheme = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<AppTheme?> duplicateTheme(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '${ApiEndpoints.themeDetail(id)}duplicate/',
      );

      final theme = AppTheme.fromJson(response.data);
      _themes.insert(0, theme);

      _isLoading = false;
      notifyListeners();
      return theme;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedTheme() {
    _selectedTheme = null;
    notifyListeners();
  }
}
