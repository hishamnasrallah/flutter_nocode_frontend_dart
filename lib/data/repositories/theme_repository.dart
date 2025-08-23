
// lib/data/repositories/theme_repository.dart
import '../services/api_service.dart';
import '../models/theme.dart';
import '../../core/constants/api_endpoints.dart';

class ThemeRepository {
  final ApiService _apiService;

  ThemeRepository(this._apiService);

  Future<List<AppTheme>> getThemes() async {
    final response = await _apiService.get(ApiEndpoints.themes);
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => AppTheme.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getThemeTemplates() async {
    final response = await _apiService.get(ApiEndpoints.themeTemplates);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<AppTheme> getThemeDetail(String id) async {
    final response = await _apiService.get(ApiEndpoints.themeDetail(id));
    return AppTheme.fromJson(response.data);
  }

  Future<AppTheme> createTheme({
    required String name,
    required String primaryColor,
    required String accentColor,
    required String backgroundColor,
    required String textColor,
    String fontFamily = 'Roboto',
    bool isDarkMode = false,
  }) async {
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
    return AppTheme.fromJson(response.data);
  }

  Future<AppTheme> updateTheme(String id, Map<String, dynamic> data) async {
    final response = await _apiService.patch(
      ApiEndpoints.themeDetail(id),
      data: data,
    );
    return AppTheme.fromJson(response.data);
  }

  Future<void> deleteTheme(String id) async {
    await _apiService.delete(ApiEndpoints.themeDetail(id));
  }

  Future<AppTheme> duplicateTheme(String id) async {
    final response = await _apiService.post(
      '${ApiEndpoints.themeDetail(id)}duplicate/',
    );
    return AppTheme.fromJson(response.data);
  }

  Future<List<Map<String, dynamic>>> getPopularThemes() async {
    final response = await _apiService.get('${ApiEndpoints.themes}popular/');
    return List<Map<String, dynamic>>.from(response.data);
  }
}