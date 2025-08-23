// lib/providers/application_provider.dart
import 'package:flutter/material.dart';
import '../data/models/application.dart';
import '../data/services/api_service.dart';
import '../core/constants/api_endpoints.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Application> _applications = [];
  Application? _selectedApplication;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _statistics;

  List<Application> get applications => _applications;
  Application? get selectedApplication => _selectedApplication;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get statistics => _statistics;

  ApplicationProvider(this._apiService);

  Future<void> fetchApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiEndpoints.applications);
      final List<dynamic> data = response.data['results'] ?? response.data;
      _applications = data.map((json) => Application.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchApplicationDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiEndpoints.applicationDetail(id));
      _selectedApplication = Application.fromJson(response.data);

      // Fetch statistics
      await fetchApplicationStatistics(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchApplicationStatistics(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.applicationStatistics(id));
      _statistics = response.data;
      notifyListeners();
    } catch (e) {
      // Statistics are optional, don't show error
    }
  }

  Future<Application?> createApplication({
  required String name,
  required String packageName,
  required String description,
  required int themeId,
  String version = '1.0.0',
}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    debugPrint('Creating application with theme ID: $themeId');

    final response = await _apiService.post(
      ApiEndpoints.applications,
      data: {
        'name': name,
        'package_name': packageName,
        'description': description,
        'theme_id': themeId,
        'version': version,
      },
    );

    debugPrint('Application created, parsing response...');
    debugPrint('Response data: ${response.data}');

    final application = Application.fromJson(response.data);
    debugPrint('Application parsed successfully: ${application.name}');

    _applications.insert(0, application);
    _isLoading = false;
    notifyListeners();
    return application;
  } catch (e, stackTrace) {
    debugPrint('Error creating application: $e');
    debugPrint('Stack trace: $stackTrace');
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
    return null;
  }
}

  Future<bool> updateApplication(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.patch(
        ApiEndpoints.applicationDetail(id),
        data: data,
      );

      final updatedApp = Application.fromJson(response.data);
      final index = _applications.indexWhere((app) => app.id.toString() == id);
      if (index != -1) {
        _applications[index] = updatedApp;
      }
      if (_selectedApplication?.id.toString() == id) {
        _selectedApplication = updatedApp;
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

  Future<bool> deleteApplication(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.delete(ApiEndpoints.applicationDetail(id));
      _applications.removeWhere((app) => app.id.toString() == id);
      if (_selectedApplication?.id.toString() == id) {
        _selectedApplication = null;
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

  Future<Map<String, dynamic>?> buildApplication(String id, {
    String buildType = 'debug',
    bool cleanBuild = false,
    bool generateSourceOnly = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiEndpoints.applicationBuild(id),
        data: {
          'build_type': buildType,
          'clean_build': cleanBuild,
          'generate_source_only': generateSourceOnly,
        },
      );

      _isLoading = false;
      notifyListeners();
      return response.data;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Application?> cloneApplication(String id, {
    required String name,
    required String packageName,
    bool cloneScreens = true,
    bool cloneDataSources = true,
    bool cloneActions = true,
    bool cloneTheme = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiEndpoints.applicationClone(id),
        data: {
          'name': name,
          'package_name': packageName,
          'clone_screens': cloneScreens,
          'clone_data_sources': cloneDataSources,
          'clone_actions': cloneActions,
          'clone_theme': cloneTheme,
        },
      );

      final application = Application.fromJson(response.data);
      _applications.insert(0, application);

      _isLoading = false;
      notifyListeners();
      return application;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> previewCode(String id, String fileType, {String? screenId}) async {
    try {
      final queryParams = <String, dynamic>{'file': fileType};
      if (screenId != null) {
        queryParams['screen_id'] = screenId;
      }

      final response = await _apiService.get(
        ApiEndpoints.applicationPreviewCode(id),
        queryParameters: queryParams,
      );

      return response.data['code'];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> exportApplicationJson(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.applicationExport(id));
      return response.data;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Application?> createFromTemplate(String templateType, String name, String packageName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '${ApiEndpoints.applications}create_from_template/',
        data: {
          'template_type': templateType,
          'name': name,
          'package_name': packageName,
        },
      );

      final application = Application.fromJson(response.data);
      _applications.insert(0, application);

      _isLoading = false;
      notifyListeners();
      return application;
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

  void clearSelectedApplication() {
    _selectedApplication = null;
    _statistics = null;
    notifyListeners();
  }
}
