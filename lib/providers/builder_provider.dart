
// lib/providers/builder_provider.dart
import 'package:flutter/material.dart';
import '../data/models/screen.dart';
import '../data/models/app_widget.dart';
import '../data/models/widget_property.dart';
import '../data/services/api_service.dart';
import '../core/constants/api_endpoints.dart';

class BuilderProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Screen> _screens = [];
  Screen? _selectedScreen;
  List<AppWidget> _widgets = [];
  AppWidget? _selectedWidget;
  Map<String, dynamic>? _widgetTypes;
  bool _isLoading = false;
  String? _error;

  List<Screen> get screens => _screens;
  Screen? get selectedScreen => _selectedScreen;
  List<AppWidget> get widgets => _widgets;
  AppWidget? get selectedWidget => _selectedWidget;
  Map<String, dynamic>? get widgetTypes => _widgetTypes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BuilderProvider(this._apiService) {
    fetchWidgetTypes();
  }

  Future<void> fetchScreens(String applicationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiEndpoints.screens,
        queryParameters: {'application': applicationId},
      );
      final List<dynamic> data = response.data['results'] ?? response.data;
      _screens = data.map((json) => Screen.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchScreenDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiEndpoints.screenDetail(id));
      _selectedScreen = Screen.fromJson(response.data);

      // Fetch widget tree
      await fetchWidgetTree(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWidgetTree(String screenId) async {
    try {
      final response = await _apiService.get(ApiEndpoints.screenWidgetTree(screenId));
      // Process widget tree
      _widgets = _processWidgetTree(response.data['tree']);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<AppWidget> _processWidgetTree(List<dynamic> tree) {
    // Convert tree structure to flat list if needed
    // This is a simplified version - you might need more complex processing
    return tree.map((node) => AppWidget.fromJson(node)).toList();
  }

  Future<void> fetchWidgetTypes() async {
    try {
      final response = await _apiService.get(ApiEndpoints.widgetTypes);
      _widgetTypes = response.data;
      notifyListeners();
    } catch (e) {
      // Widget types are cached, so don't show error
    }
  }

  Future<Screen?> createScreen({
    required String applicationId,
    required String name,
    required String routeName,
    bool isHomeScreen = false,
    String? appBarTitle,
    bool showAppBar = true,
    bool showBackButton = true,
    String? backgroundColor,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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

      final screen = Screen.fromJson(response.data);
      _screens.add(screen);

      _isLoading = false;
      notifyListeners();
      return screen;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<AppWidget?> addWidget({
    required String screenId,
    required String widgetType,
    int? parentWidgetId,
    int order = 0,
    String? widgetId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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

      final widget = AppWidget.fromJson(response.data);
      _widgets.add(widget);

      _isLoading = false;
      notifyListeners();
      return widget;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateWidgetProperty({
    required String widgetId,
    required String propertyName,
    required String propertyType,
    required dynamic value,
  }) async {
    try {
      final data = {
        'widget_id': widgetId,
        'properties': [
          {
            'property_name': propertyName,
            'property_type': propertyType,
            _getValueField(propertyType): value,
          }
        ],
      };

      await _apiService.post(
        ApiEndpoints.widgetPropertiesBulkUpdate,
        data: data,
      );

      // Update local widget properties
      final widgetIndex = _widgets.indexWhere((w) => w.id.toString() == widgetId);
      if (widgetIndex != -1) {
        // Update the property in the local widget
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  String _getValueField(String propertyType) {
    switch (propertyType) {
      case 'string':
        return 'string_value';
      case 'integer':
        return 'integer_value';
      case 'decimal':
        return 'decimal_value';
      case 'boolean':
        return 'boolean_value';
      case 'color':
        return 'color_value';
      case 'alignment':
        return 'alignment_value';
      case 'url':
        return 'url_value';
      case 'json':
        return 'json_value';
      case 'action_reference':
        return 'action_reference';
      case 'data_source_field_reference':
        return 'data_source_field_reference';
      case 'screen_reference':
        return 'screen_reference';
      default:
        return 'string_value';
    }
  }

  Future<bool> deleteWidget(String widgetId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.delete(ApiEndpoints.widgetDetail(widgetId));
      _widgets.removeWhere((widget) => widget.id.toString() == widgetId);

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

  Future<bool> reorderWidget(String widgetId, int newOrder) async {
    try {
      await _apiService.post(
        '${ApiEndpoints.widgetDetail(widgetId)}reorder/',
        data: {'order': newOrder},
      );

      // Update local widget order
      final widgetIndex = _widgets.indexWhere((w) => w.id.toString() == widgetId);
      if (widgetIndex != -1) {
        // Update order
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void selectWidget(AppWidget? widget) {
    _selectedWidget = widget;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedScreen = null;
    _selectedWidget = null;
    _widgets = [];
    notifyListeners();
  }
}