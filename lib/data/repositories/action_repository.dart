// lib/data/repositories/action_repository.dart
import '../services/api_service.dart';
import '../models/action.dart';
import '../../core/constants/api_endpoints.dart';

class ActionRepository {
  final ApiService _apiService;

  ActionRepository(this._apiService);

  Future<List<AppAction>> getActions({String? applicationId}) async {
    final queryParams = applicationId != null ? {'application': applicationId} : null;

    final response = await _apiService.get(
      ApiEndpoints.actions,
      queryParameters: queryParams,
    );

    // Handle paginated response
    List<dynamic> data;
    if (response.data is Map && response.data.containsKey('results')) {
      data = response.data['results'] as List;
    } else if (response.data is List) {
      data = response.data as List;
    } else {
      data = [];
    }

    return data.map((json) => AppAction.fromJson(json)).toList();
  }

  Future<AppAction> getActionDetail(String id) async {
    final response = await _apiService.get(ApiEndpoints.actionDetail(id));
    return AppAction.fromJson(response.data);
  }

  Future<AppAction> createAction({
    required String applicationId,
    required String name,
    required String actionType,
    int? targetScreen,
    int? apiDataSource,
    String? parameters,
    String? dialogTitle,
    String? dialogMessage,
    String? url,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.actions,
      data: {
        'application': applicationId,
        'name': name,
        'action_type': actionType,
        if (targetScreen != null) 'target_screen': targetScreen,
        if (apiDataSource != null) 'api_data_source': apiDataSource,
        if (parameters != null) 'parameters': parameters,
        if (dialogTitle != null) 'dialog_title': dialogTitle,
        if (dialogMessage != null) 'dialog_message': dialogMessage,
        if (url != null) 'url': url,
      },
    );
    return AppAction.fromJson(response.data);
  }

  Future<AppAction> updateAction(String id, Map<String, dynamic> data) async {
    final response = await _apiService.patch(
      ApiEndpoints.actionDetail(id),
      data: data,
    );
    return AppAction.fromJson(response.data);
  }

  Future<void> deleteAction(String id) async {
    await _apiService.delete(ApiEndpoints.actionDetail(id));
  }
}