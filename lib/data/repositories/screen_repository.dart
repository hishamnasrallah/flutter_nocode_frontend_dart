
// lib/data/repositories/screen_repository.dart
import '../services/api_service.dart';
import '../models/screen.dart';
import '../models/app_widget.dart';
import '../models/widget_property.dart';
import '../../core/constants/api_endpoints.dart';

class ScreenRepository {
  final ApiService _apiService;

  ScreenRepository(this._apiService);

  Future<List<Screen>> getScreens({String? applicationId}) async {
    final queryParams = applicationId != null ? {'application': applicationId} : null;
    final response = await _apiService.get(
      ApiEndpoints.screens,
      queryParameters: queryParams,
    );
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => Screen.fromJson(json)).toList();
  }

  Future<Screen> getScreenDetail(String id) async {
    final response = await _apiService.get(ApiEndpoints.screenDetail(id));
    return Screen.fromJson(response.data);
  }

  Future<Screen> createScreen({
    required String applicationId,
    required String name,
    required String routeName,
    bool isHomeScreen = false,
    String? appBarTitle,
    bool showAppBar = true,
    bool showBackButton = true,
    String? backgroundColor,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.screens,
      data: {
        'application': applicationId,
        'name': name,
        'route_name': routeName,
        'is_home_screen': isHomeScreen,
        'app_bar_title': appBarTitle ?? name,
        'show_app_bar': showAppBar,
        'show_back_button': showBackButton,
        'background_color': backgroundColor,
      },
    );
    return Screen.fromJson(response.data);
  }

  Future<Screen> updateScreen(String id, Map<String, dynamic> data) async {
    final response = await _apiService.patch(
      ApiEndpoints.screenDetail(id),
      data: data,
    );
    return Screen.fromJson(response.data);
  }

  Future<void> deleteScreen(String id) async {
    await _apiService.delete(ApiEndpoints.screenDetail(id));
  }

  Future<Screen> duplicateScreen(String id) async {
    final response = await _apiService.post(
      ApiEndpoints.screenDuplicate(id),
    );
    return Screen.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getWidgetTree(String screenId) async {
    final response = await _apiService.get(ApiEndpoints.screenWidgetTree(screenId));
    return response.data;
  }

  Future<Screen> setAsHomeScreen(String id) async {
    final response = await _apiService.post(
      '${ApiEndpoints.screenDetail(id)}set_home/',
    );
    return Screen.fromJson(response.data);
  }

  Future<List<Map<String, dynamic>>> getScreenTemplates() async {
    final response = await _apiService.get('${ApiEndpoints.screens}templates/');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // Widget operations
  Future<List<AppWidget>> getWidgets({String? screenId, String? parentId}) async {
    final queryParams = <String, dynamic>{};
    if (screenId != null) queryParams['screen'] = screenId;
    if (parentId != null) queryParams['parent'] = parentId;

    final response = await _apiService.get(
      ApiEndpoints.widgets,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final List<dynamic> data = response.data['results'] ?? response.data;
    return data.map((json) => AppWidget.fromJson(json)).toList();
  }

  Future<AppWidget> createWidget({
    required String screenId,
    required String widgetType,
    int? parentWidgetId,
    int order = 0,
    String? widgetId,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.widgets,
      data: {
        'screen': screenId,
        'widget_type': widgetType,
        'parent_widget': parentWidgetId,
        'order': order,
        'widget_id': widgetId,
      },
    );
    return AppWidget.fromJson(response.data);
  }

  Future<AppWidget> updateWidget(String id, Map<String, dynamic> data) async {
    final response = await _apiService.patch(
      ApiEndpoints.widgetDetail(id),
      data: data,
    );
    return AppWidget.fromJson(response.data);
  }

  Future<void> deleteWidget(String id) async {
    await _apiService.delete(ApiEndpoints.widgetDetail(id));
  }

  Future<AppWidget> duplicateWidget(String id) async {
    final response = await _apiService.post(
      '${ApiEndpoints.widgetDetail(id)}duplicate/',
    );
    return AppWidget.fromJson(response.data);
  }

  Future<void> reorderWidget(String id, int newOrder) async {
    await _apiService.post(
      '${ApiEndpoints.widgetDetail(id)}reorder/',
      data: {'order': newOrder},
    );
  }

  Future<void> moveWidget(String id, String? newParentId) async {
    await _apiService.post(
      '${ApiEndpoints.widgetDetail(id)}move/',
      data: {'new_parent_id': newParentId},
    );
  }

  Future<Map<String, dynamic>> getWidgetTypes() async {
    final response = await _apiService.get(ApiEndpoints.widgetTypes);
    return response.data;
  }

  Future<List<AppWidget>> bulkCreateWidgets(String screenId, List<Map<String, dynamic>> widgets) async {
    final response = await _apiService.post(
      ApiEndpoints.widgetBulkCreate,
      data: {
        'screen_id': screenId,
        'widgets': widgets,
      },
    );
    final List<dynamic> data = response.data;
    return data.map((json) => AppWidget.fromJson(json)).toList();
  }

  // Widget Properties
  Future<List<WidgetProperty>> updateWidgetProperties(String widgetId, List<Map<String, dynamic>> properties) async {
    final response = await _apiService.post(
      ApiEndpoints.widgetPropertiesBulkUpdate,
      data: {
        'widget_id': widgetId,
        'properties': properties,
      },
    );
    final List<dynamic> data = response.data;
    return data.map((json) => WidgetProperty.fromJson(json)).toList();
  }

  Future<WidgetProperty> createWidgetProperty({
    required String widgetId,
    required String propertyName,
    required String propertyType,
    required dynamic value,
  }) async {
    final data = {
      'widget': widgetId,
      'property_name': propertyName,
      'property_type': propertyType,
    };

    // Add the appropriate value field based on property type
    switch (propertyType) {
      case 'string':
        data['string_value'] = value;
        break;
      case 'integer':
        data['integer_value'] = value;
        break;
      case 'decimal':
        data['decimal_value'] = value;
        break;
      case 'boolean':
        data['boolean_value'] = value;
        break;
      case 'color':
        data['color_value'] = value;
        break;
      case 'alignment':
        data['alignment_value'] = value;
        break;
      case 'url':
        data['url_value'] = value;
        break;
      case 'json':
        data['json_value'] = value;
        break;
      case 'action_reference':
        data['action_reference'] = value;
        break;
      case 'data_source_field_reference':
        data['data_source_field_reference'] = value;
        break;
      case 'screen_reference':
        data['screen_reference'] = value;
        break;
    }

    final response = await _apiService.post(
      ApiEndpoints.widgetProperties,
      data: data,
    );
    return WidgetProperty.fromJson(response.data);
  }
}