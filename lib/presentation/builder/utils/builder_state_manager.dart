// lib/presentation/builder/utils/builder_state_manager.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/builder_provider.dart';
import '../components/dialogs/add_screen_dialog.dart';
import '../components/dialogs/screen_settings_dialog.dart';
import '../components/dialogs/preview_dialog.dart';
import '../components/dialogs/code_preview_dialog.dart';
import '../components/widget_tree/widget_tree_dialog.dart';

class BuilderStateManager {
  final String applicationId;
  final VoidCallback onStateChanged;

  String? _selectedScreenId;
  double _zoomLevel = 1.0;
  bool _showGrid = true;
  bool _showOutlines = true;

  String? get selectedScreenId => _selectedScreenId;
  double get zoomLevel => _zoomLevel;
  bool get showGrid => _showGrid;
  bool get showOutlines => _showOutlines;

  BuilderStateManager({
    required this.applicationId,
    required this.onStateChanged,
  });

  void selectScreen(String screenId) {
    _selectedScreenId = screenId;
    onStateChanged();
  }

  void zoomIn() {
    _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 2.0);
    onStateChanged();
  }

  void zoomOut() {
    _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 2.0);
    onStateChanged();
  }

  void toggleGrid() {
    _showGrid = !_showGrid;
    onStateChanged();
  }

  void toggleOutlines() {
    _showOutlines = !_showOutlines;
    onStateChanged();
  }

  String getPropertyType(dynamic value) {
    if (value is String) return 'string';
    if (value is int) return 'integer';
    if (value is double) return 'decimal';
    if (value is bool) return 'boolean';
    if (value is Color) return 'color';
    return 'string';
  }

  Future<bool> confirmDelete(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void showAddScreenDialog(
    BuildContext context,
    String applicationId,
    {required VoidCallback onSuccess}
  ) {
    showDialog(
      context: context,
      builder: (context) => AddScreenDialog(
        applicationId: applicationId,
        onSuccess: onSuccess,
      ),
    );
  }

  void showScreenSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ScreenSettingsDialog(),
    );
  }

  void showPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PreviewDialog(),
    );
  }

  void showCodePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CodePreviewDialog(),
    );
  }

  void showWidgetTree(BuildContext context) {
    final builderProvider = context.read<BuilderProvider>();
    showDialog(
      context: context,
      builder: (context) => WidgetTreeDialog(
        widgets: builderProvider.widgets,
      ),
    );
  }

  void dispose() {
    // Clean up any resources
  }
}
