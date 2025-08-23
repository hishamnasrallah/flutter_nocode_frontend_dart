
// lib/core/constants/api_endpoints.dart
class ApiEndpoints {
  // Update this with your actual backend URL
  static const String baseUrl = 'http://localhost:8000';

  // Auth endpoints
  static const String login = '/api/auth/login/';
  static const String register = '/api/auth/register/';
  static const String logout = '/api/auth/logout/';
  static const String refreshToken = '/api/auth/refresh/';
  static const String me = '/api/auth/me/';
  static const String updateProfile = '/api/auth/update-profile/';
  static const String changePassword = '/api/auth/change-password/';

  // Application endpoints
  static const String applications = '/api/v1/applications/';
  static String applicationDetail(String id) => '/api/v1/applications/$id/';
  static String applicationClone(String id) => '/api/v1/applications/$id/clone/';
  static String applicationBuild(String id) => '/api/v1/applications/$id/build/';
  static String applicationPreviewCode(String id) => '/api/v1/applications/$id/preview_code/';
  static String applicationExport(String id) => '/api/v1/applications/$id/export_json/';
  static String applicationStatistics(String id) => '/api/v1/applications/$id/statistics/';

  // Theme endpoints
  static const String themes = '/api/v1/themes/';
  static String themeDetail(String id) => '/api/v1/themes/$id/';
  static const String themeTemplates = '/api/v1/themes/templates/';

  // Screen endpoints
  static const String screens = '/api/v1/screens/';
  static String screenDetail(String id) => '/api/v1/screens/$id/';
  static String screenDuplicate(String id) => '/api/v1/screens/$id/duplicate/';
  static String screenWidgetTree(String id) => '/api/v1/screens/$id/widget_tree/';

  // Widget endpoints
  static const String widgets = '/api/v1/widgets/';
  static String widgetDetail(String id) => '/api/v1/widgets/$id/';
  static const String widgetTypes = '/api/v1/widgets/widget_types/';
  static const String widgetBulkCreate = '/api/v1/widgets/bulk_create/';

  // Widget Property endpoints
  static const String widgetProperties = '/api/v1/widget-properties/';
  static const String widgetPropertiesBulkUpdate = '/api/v1/widget-properties/bulk_update/';

  // Action endpoints
  static const String actions = '/api/v1/actions/';
  static String actionDetail(String id) => '/api/v1/actions/$id/';
  static const String actionTypes = '/api/v1/actions/action_types/';

  // Data Source endpoints
  static const String dataSources = '/api/v1/data-sources/';
  static String dataSourceDetail(String id) => '/api/v1/data-sources/$id/';
  static String dataSourceTestConnection(String id) => '/api/v1/data-sources/$id/test_connection/';
  static String dataSourceAutoDetectFields(String id) => '/api/v1/data-sources/$id/auto_detect_fields/';

  // Data Source Field endpoints
  static const String dataSourceFields = '/api/v1/data-source-fields/';
  static const String dataSourceFieldsBulkCreate = '/api/v1/data-source-fields/bulk_create/';

  // Build History endpoints
  static const String buildHistory = '/api/v1/build-history/';
  static String buildHistoryDetail(String id) => '/api/v1/build-history/$id/';
  static String buildHistoryLogs(String id) => '/api/v1/build-history/$id/logs/';
  static String buildHistoryDownloadApk(String id) => '/api/v1/build-history/$id/download_apk/';
  static String buildHistoryDownloadSource(String id) => '/api/v1/build-history/$id/download_source/';
}
