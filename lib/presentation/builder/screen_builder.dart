// lib/presentation/builder/screen_builder.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/builder_provider.dart';
import '../../providers/application_provider.dart';
import '../../core/constants/app_colors.dart';
import 'widget_picker.dart';
import 'property_editor.dart';
import 'components/canvas/builder_canvas.dart';
import 'components/toolbar/builder_app_bar.dart';
import 'components/toolbar/screen_selector.dart';
import 'utils/builder_state_manager.dart';

class ScreenBuilder extends StatefulWidget {
  final String applicationId;

  const ScreenBuilder({super.key, required this.applicationId});

  @override
  State<ScreenBuilder> createState() => _ScreenBuilderState();
}

class _ScreenBuilderState extends State<ScreenBuilder> {
  late final BuilderStateManager _stateManager;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _stateManager = BuilderStateManager(
      applicationId: widget.applicationId,
      onStateChanged: () => setState(() {}),
    );
    _initializeBuilder();
  }

  Future<void> _initializeBuilder() async {
    final builderProvider = context.read<BuilderProvider>();
    await builderProvider.fetchScreens(widget.applicationId);

    if (builderProvider.screens.isNotEmpty && mounted) {
      final firstScreenId = builderProvider.screens.first.id.toString();
      _stateManager.selectScreen(firstScreenId);

      await builderProvider.fetchScreenDetail(firstScreenId);
      await builderProvider.fetchWidgetsForScreen(firstScreenId);

      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final builderProvider = context.watch<BuilderProvider>();
    final applicationProvider = context.watch<ApplicationProvider>();

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Builder...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: BuilderAppBar(
        applicationName: applicationProvider.selectedApplication?.name ?? 'App',
        stateManager: _stateManager,
        onRefresh: _initializeBuilder,
        onSave: _saveChanges,
      ),
      body: Row(
        children: [
          // Left sidebar - Widget palette
          _buildWidgetPalette(builderProvider),

          // Center - Canvas area
          Expanded(
            child: Column(
              children: [
                // Screen selector
                ScreenSelector(
                  screens: builderProvider.screens,
                  selectedScreenId: _stateManager.selectedScreenId,
                  onScreenSelected: (screenId) => _handleScreenSelection(screenId),
                  onAddScreen: () => _handleAddScreen(context),
                  onScreenSettings: () => _handleScreenSettings(context),
                ),

                // Canvas
                Expanded(
                  child: BuilderCanvas(
                    stateManager: _stateManager,
                    selectedScreen: builderProvider.selectedScreen,
                    widgets: builderProvider.widgets,
                    selectedWidget: builderProvider.selectedWidget,
                    onWidgetSelected: (widget) {
                      builderProvider.selectWidget(widget);
                    },
                    onWidgetAdded: _handleWidgetAdded,
                    onWidgetDeleted: _handleWidgetDeleted,
                    onWidgetReordered: _handleWidgetReordered,
                    onWidgetDuplicated: _handleWidgetDuplicated,
                  ),
                ),
              ],
            ),
          ),

          // Right sidebar - Properties panel
          _buildPropertiesPanel(builderProvider),
        ],
      ),
    );
  }

  Widget _buildWidgetPalette(BuilderProvider builderProvider) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          _buildWidgetPaletteHeader(builderProvider),
          Expanded(
            child: WidgetPicker(
              onWidgetSelected: _handleWidgetAdded,
              screenId: _stateManager.selectedScreenId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetPaletteHeader(BuilderProvider builderProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Widget Toolkit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_tree, size: 20),
            onPressed: () => _stateManager.showWidgetTree(context),
            tooltip: 'View Widget Tree',
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesPanel(BuilderProvider builderProvider) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: PropertyEditor(
        widget: builderProvider.selectedWidget,
        onPropertyChanged: _handlePropertyChanged,
      ),
    );
  }

  // Event Handlers
  Future<void> _handleScreenSelection(String screenId) async {
    final builderProvider = context.read<BuilderProvider>();
    _stateManager.selectScreen(screenId);

    await builderProvider.fetchScreenDetail(screenId);
    await builderProvider.fetchWidgetsForScreen(screenId);
  }

  Future<void> _handleWidgetAdded(Map<String, dynamic> widgetData) async {
    if (_stateManager.selectedScreenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a screen first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final builderProvider = context.read<BuilderProvider>();
    final success = await builderProvider.addWidget(
      screenId: _stateManager.selectedScreenId!,
      widgetType: widgetData['type'] ?? widgetData['name'],
    );

    if (success != null) {
      await builderProvider.fetchWidgetsForScreen(_stateManager.selectedScreenId!);
      _showSuccessMessage('Widget added successfully');
    } else {
      _showErrorMessage('Failed to add widget: ${builderProvider.error}');
    }
  }

  Future<void> _handleWidgetDeleted(dynamic widget) async {
    final confirmed = await _stateManager.confirmDelete(
      context,
      'Delete Widget',
      'Are you sure you want to delete this ${widget.widgetType} widget?',
    );

    if (confirmed) {
      final builderProvider = context.read<BuilderProvider>();
      final success = await builderProvider.deleteWidget(widget.id.toString());

      if (success) {
        await builderProvider.fetchWidgetsForScreen(_stateManager.selectedScreenId!);
        _showSuccessMessage('Widget deleted');
      }
    }
  }

  Future<void> _handleWidgetReordered(dynamic widget, int newOrder) async {
    final builderProvider = context.read<BuilderProvider>();
    await builderProvider.reorderWidget(widget.id.toString(), newOrder);
    await builderProvider.fetchWidgetsForScreen(_stateManager.selectedScreenId!);
  }

  Future<void> _handleWidgetDuplicated(dynamic widget) async {
    // TODO: Implement widget duplication
    _showInfoMessage('Widget duplication coming soon!');
  }

  void _handlePropertyChanged(String propertyName, dynamic value) {
    final builderProvider = context.read<BuilderProvider>();
    if (builderProvider.selectedWidget != null) {
      builderProvider.updateWidgetProperty(
        widgetId: builderProvider.selectedWidget!.id.toString(),
        propertyName: propertyName,
        propertyType: _stateManager.getPropertyType(value),
        value: value,
      );
    }
  }

  void _handleAddScreen(BuildContext context) {
    _stateManager.showAddScreenDialog(
      context,
      widget.applicationId,
      onSuccess: _initializeBuilder,
    );
  }

  void _handleScreenSettings(BuildContext context) {
    _stateManager.showScreenSettingsDialog(context);
  }

  void _saveChanges() {
    _showSuccessMessage('Changes saved!');
  }

  // Helper methods
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _stateManager.dispose();
    super.dispose();
  }
}