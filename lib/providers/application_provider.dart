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

      debugPrint('📱 Applications API called: ${ApiEndpoints.applications}');
      debugPrint('📱 Response type: ${response.data.runtimeType}');
      debugPrint('📱 Full Response: ${response.data}');

      // Handle different response formats
      List<dynamic> data;
      if (response.data is List) {
        // Direct array response
        data = response.data as List;
        debugPrint('📱 Direct array with ${data.length} items');
      } else if (response.data is Map) {
        final responseMap = response.data as Map<String, dynamic>;
        debugPrint('📱 Response map keys: ${responseMap.keys.toList()}');

        if (responseMap.containsKey('results')) {
          // Paginated response
          data = responseMap['results'] as List;
          debugPrint('📱 Found "results" key with ${data.length} items');
        } else if (responseMap.containsKey('data')) {
          // Sometimes APIs wrap in 'data' key
          data = responseMap['data'] as List;
          debugPrint('📱 Found "data" key with ${data.length} items');
        } else if (responseMap.containsKey('applications')) {
          // Sometimes APIs use the resource name
          data = responseMap['applications'] as List;
          debugPrint('📱 Found "applications" key with ${data.length} items');
        } else {
          // Empty or unexpected format
          data = [];
          debugPrint('📱 No standard key found. Available keys: ${responseMap.keys}');
        }
      } else {
        data = [];
        debugPrint('📱 Unexpected response format: ${response.data.runtimeType}');
      }

      debugPrint('📱 About to parse ${data.length} applications');

      _applications = [];
      for (int i = 0; i < data.length; i++) {
        try {
          final app = Application.fromJson(data[i]);
          _applications.add(app);
          debugPrint('✅ Parsed application ${i + 1}: ${app.name}');
        } catch (e) {
          debugPrint('❌ Failed to parse application at index $i: $e');
          debugPrint('❌ Data that failed: ${data[i]}');
        }
      }

      debugPrint('📱 Successfully loaded ${_applications.length} applications');

    } catch (e, stackTrace) {
      _error = e.toString();
      debugPrint('❌ Error fetching applications: $_error');
      debugPrint('❌ Stack trace: $stackTrace');
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
      debugPrint('📱 Fetching application detail for ID: $id');
      final response = await _apiService.get(ApiEndpoints.applicationDetail(id));

      debugPrint('📱 Application Detail Response Type: ${response.data.runtimeType}');
      debugPrint('📱 Application Detail Response: ${response.data}');

      // Check if response is wrapped
      dynamic applicationData;
      if (response.data is Map) {
        final responseMap = response.data as Map<String, dynamic>;

        // Check if the application data is wrapped in a key
        if (responseMap.containsKey('application')) {
          applicationData = responseMap['application'];
          debugPrint('📱 Found application data in "application" key');
        } else if (responseMap.containsKey('data')) {
          applicationData = responseMap['data'];
          debugPrint('📱 Found application data in "data" key');
        } else {
          // Direct response
          applicationData = response.data;
          debugPrint('📱 Using direct response data');
        }
      } else {
        applicationData = response.data;
      }

      debugPrint('📱 Parsing application data: $applicationData');

      _selectedApplication = Application.fromJson(applicationData);

      debugPrint('✅ Successfully parsed application: ${_selectedApplication?.name}');

      // Fetch statistics
      await fetchApplicationStatistics(id);
    } catch (e, stackTrace) {
      _error = e.toString();
      debugPrint('❌ Error fetching application detail: $_error');
      debugPrint('❌ Stack trace: $stackTrace');
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
      debugPrint('⚠️ Could not fetch statistics: $e');
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