// lib/data/repositories/application_repository.dart
import '../services/api_service.dart';
import '../models/application.dart';
import '../models/screen.dart';
import '../models/app_widget.dart';
import '../models/build_history.dart';
import '../../core/constants/api_endpoints.dart';

class ApplicationRepository {
  final ApiService _apiService;

  ApplicationRepository(this._apiService);

  Future<List<Application>> getApplications() async {
    final response = await _apiService.get(ApiEndpoints.applications);
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => Application.fromJson(json)).toList();
  }

  Future<Application> getApplicationDetail(String id) async {
    final response = await _apiService.get(ApiEndpoints.applicationDetail(id));
    return Application.fromJson(response.data);
  }

  Future<Application> createApplication({
    required String name,
    required String packageName,
    required String description,
    required int themeId,
    String version = '1.0.0',
  }) async {
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
    return Application.fromJson(response.data);
  }

  Future<Application> updateApplication(String id, Map<String, dynamic> data) async {
    final response = await _apiService.patch(
      ApiEndpoints.applicationDetail(id),
      data: data,
    );
    return Application.fromJson(response.data);
  }

  Future<void> deleteApplication(String id) async {
    await _apiService.delete(ApiEndpoints.applicationDetail(id));
  }

  Future<Map<String, dynamic>> buildApplication(String id, {
    String buildType = 'debug',
    bool cleanBuild = false,
    bool generateSourceOnly = false,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.applicationBuild(id),
      data: {
        'build_type': buildType,
        'clean_build': cleanBuild,
        'generate_source_only': generateSourceOnly,
      },
    );
    return response.data;
  }

  Future<Application> cloneApplication(String id, {
    required String name,
    required String packageName,
    bool cloneScreens = true,
    bool cloneDataSources = true,
    bool cloneActions = true,
    bool cloneTheme = false,
  }) async {
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
    return Application.fromJson(response.data);
  }

  Future<String> previewCode(String id, String fileType, {String? screenId}) async {
    final queryParams = <String, dynamic>{'file': fileType};
    if (screenId != null) {
      queryParams['screen_id'] = screenId;
    }

    final response = await _apiService.get(
      ApiEndpoints.applicationPreviewCode(id),
      queryParameters: queryParams,
    );
    return response.data['code'];
  }

  Future<Map<String, dynamic>> exportApplicationJson(String id) async {
    final response = await _apiService.get(ApiEndpoints.applicationExport(id));
    return response.data;
  }

  Future<Map<String, dynamic>> getApplicationStatistics(String id) async {
    final response = await _apiService.get(ApiEndpoints.applicationStatistics(id));
    return response.data;
  }

  Future<Application> createFromTemplate(String templateType, String name, String packageName) async {
    final response = await _apiService.post(
      '${ApiEndpoints.applications}create_from_template/',
      data: {
        'template_type': templateType,
        'name': name,
        'package_name': packageName,
      },
    );
    return Application.fromJson(response.data);
  }

  Future<List<BuildHistory>> getBuildHistory(String applicationId) async {
    final response = await _apiService.get(
      ApiEndpoints.buildHistory,
      queryParameters: {'application': applicationId},
    );
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => BuildHistory.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> getBuildLogs(String buildId) async {
    final response = await _apiService.get(ApiEndpoints.buildHistoryLogs(buildId));
    return response.data;
  }

  Future<void> downloadApk(String buildId, String savePath) async {
    final response = await _apiService.get(ApiEndpoints.buildHistoryDownloadApk(buildId));
    final downloadUrl = response.data['download_url'];
    await _apiService.downloadFile(downloadUrl, savePath);
  }

  Future<void> downloadSourceCode(String buildId, String savePath) async {
    final response = await _apiService.get(ApiEndpoints.buildHistoryDownloadSource(buildId));
    final downloadUrl = response.data['download_url'];
    await _apiService.downloadFile(downloadUrl, savePath);
  }
}

