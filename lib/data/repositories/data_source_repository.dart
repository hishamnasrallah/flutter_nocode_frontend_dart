// lib/data/repositories/data_source_repository.dart
import '../services/api_service.dart';
import '../models/data_source.dart';
import '../../core/constants/api_endpoints.dart';

class DataSourceRepository {
  final ApiService _apiService;

  DataSourceRepository(this._apiService);

  Future<List<DataSource>> getDataSources({String? applicationId}) async {
    final queryParams = applicationId != null ? {'application': applicationId} : null;

    final response = await _apiService.get(
      ApiEndpoints.dataSources,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => DataSource.fromJson(json)).toList();
  }

  Future<DataSource> getDataSourceDetail(String id) async {
    final response = await _apiService.get(ApiEndpoints.dataSourceDetail(id));
    return DataSource.fromJson(response.data);
  }

  Future<DataSource> createDataSource({
    required String applicationId,
    required String name,
    required String dataSourceType,
    String? baseUrl,
    String? endpoint,
    String method = 'GET',
    String? headers,
    bool useDynamicBaseUrl = false,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.dataSources,
      data: {
        'application': applicationId,
        'name': name,
        'data_source_type': dataSourceType,
        'base_url': baseUrl,
        'endpoint': endpoint,
        'method': method,
        'headers': headers,
        'use_dynamic_base_url': useDynamicBaseUrl,
      },
    );
    return DataSource.fromJson(response.data);
  }

  Future<DataSource> updateDataSource(String id, Map<String, dynamic> data) async {
    final response = await _apiService.patch(
      ApiEndpoints.dataSourceDetail(id),
      data: data,
    );
    return DataSource.fromJson(response.data);
  }

  Future<void> deleteDataSource(String id) async {
    await _apiService.delete(ApiEndpoints.dataSourceDetail(id));
  }

  Future<Map<String, dynamic>> testConnection(String id) async {
    final response = await _apiService.post(
      ApiEndpoints.dataSourceTestConnection(id),
    );
    return response.data;
  }

  Future<List<Map<String, dynamic>>> autoDetectFields(String id) async {
    final response = await _apiService.post(
      ApiEndpoints.dataSourceAutoDetectFields(id),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }
}