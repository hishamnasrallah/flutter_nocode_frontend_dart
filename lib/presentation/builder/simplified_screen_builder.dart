// lib/presentation/builder/simplified_screen_builder.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_widget.dart';
import '../../providers/builder_provider.dart';
import '../../providers/application_provider.dart';
import '../../core/constants/app_colors.dart';
import 'components/widget_palette/simplified_widget_picker.dart';
import 'components/properties/visual_property_editor.dart';
import 'components/canvas/interactive_canvas.dart';
import 'components/toolbar/builder_app_bar.dart';
import 'components/toolbar/screen_selector.dart';
import 'utils/builder_state_manager.dart';

class SimplifiedScreenBuilder extends StatefulWidget {
  final String applicationId;

  const SimplifiedScreenBuilder({super.key, required this.applicationId});

  @override
  State<SimplifiedScreenBuilder> createState() => _SimplifiedScreenBuilderState();
}

class _SimplifiedScreenBuilderState extends State<SimplifiedScreenBuilder> {
  late final BuilderStateManager _stateManager;
  bool _isInitialized = false;
  bool _showWidgetPalette = true;
  bool _showProperties = true;

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

      // Add welcome animation
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isInitialized = true;
      });
    } else {
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 24),
                Text(
                  'Loading Builder...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
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
      body: Column(
        children: [
          // Screen selector with better UX
          ScreenSelector(
            screens: builderProvider.screens,
            selectedScreenId: _stateManager.selectedScreenId,
            onScreenSelected: _handleScreenSelection,
            onAddScreen: () => _handleAddScreen(context),
            onScreenSettings: () => _handleScreenSettings(context),
          ),

          // Main builder area
          Expanded(
            child: Row(
              children: [
                // Left Panel - Widget Palette
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _showWidgetPalette ? 280 : 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: _showWidgetPalette
                      ? SimplifiedWidgetPicker(
                          onWidgetSelected: _handleWidgetAdded,
                          screenId: _stateManager.selectedScreenId,
                        )
                      : _buildCollapsedPanel(
                          icon: Icons.widgets,
                          onTap: () => setState(() => _showWidgetPalette = true),
                        ),
                ),

                // Center - Canvas
                Expanded(
                  child: InteractiveCanvas(
                    stateManager: _stateManager,
                    selectedScreen: builderProvider.selectedScreen,
                    widgets: builderProvider.widgets,
                    selectedWidget: builderProvider.selectedWidget,
                    onWidgetSelected: (widget) {
                      builderProvider.selectWidget(widget);
                      if (widget != null && !_showProperties) {
                        setState(() => _showProperties = true);
                      }
                    },
                    onWidgetAdded: _handleWidgetAdded,
                    onWidgetDeleted: _handleWidgetDeleted,
                    onWidgetReordered: _handleWidgetReordered,
                    onWidgetMoved: _handleWidgetMoved,
                  ),
                ),

                // Right Panel - Properties
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _showProperties ? 320 : 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(-2, 0),
                      ),
                    ],
                  ),
                  child: _showProperties
                      ? VisualPropertyEditor(
                          widget: builderProvider.selectedWidget,
                          onPropertyChanged: _handlePropertyChanged,
                          onClose: () => setState(() => _showProperties = false),
                        )
                      : _buildCollapsedPanel(
                          icon: Icons.tune,
                          onTap: () => setState(() => _showProperties = true),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingHelp(),
    );
  }

  Widget _buildCollapsedPanel({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        alignment: Alignment.center,
        child: RotatedBox(
          quarterTurns: -1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Icon(Icons.chevron_left, size: 20, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHelp() {
    return FloatingActionButton(
      mini: true,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.help_outline, size: 20),
      onPressed: () {
        _showHelpDialog();
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Quick Help'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(
                '🎯 Drag & Drop',
                'Drag widgets from the left panel and drop them on the canvas',
              ),
              _buildHelpItem(
                '✏️ Edit Properties',
                'Click any widget to edit its properties in the right panel',
              ),
              _buildHelpItem(
                '🔄 Reorder',
                'Drag widgets to reorder them within their parent',
              ),
              _buildHelpItem(
                '👁️ Preview',
                'Click the preview button to see your app in action',
              ),
              _buildHelpItem(
                '💾 Auto-Save',
                'Your changes are saved automatically',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
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
      _showSnackBar('Please select a screen first', isError: true);
      return;
    }

    final builderProvider = context.read<BuilderProvider>();

    // Show adding animation
    _showSnackBar('Adding ${widgetData['name']}...', duration: 1);

    final success = await builderProvider.addWidget(
      screenId: _stateManager.selectedScreenId!,
      widgetType: widgetData['type'] ?? widgetData['name'],
    );

    if (success != null) {
      await builderProvider.fetchWidgetsForScreen(_stateManager.selectedScreenId!);
      _showSnackBar('${widgetData['name']} added!', isSuccess: true);

      // Auto-select the new widget
      builderProvider.selectWidget(success);
      if (!_showProperties) {
        setState(() => _showProperties = true);
      }
    } else {
      _showSnackBar('Failed to add widget', isError: true);
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
        _showSnackBar('Widget deleted', isSuccess: true);
      }
    }
  }

  Future<void> _handleWidgetReordered(dynamic widget, int newOrder) async {
    final builderProvider = context.read<BuilderProvider>();
    await builderProvider.reorderWidget(widget.id.toString(), newOrder);
    await builderProvider.fetchWidgetsForScreen(_stateManager.selectedScreenId!);
  }

  Future<void> _handleWidgetMoved(AppWidget widget, AppWidget? newParent) async {
    // Implement widget moving between parents
    _showSnackBar('Widget moved!', isSuccess: true);
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

      // Refresh widgets to show changes immediately
      builderProvider.fetchWidgetsForScreen(_stateManager.selectedScreenId!);
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
    _showSnackBar('All changes saved!', isSuccess: true);
  }

  void _showSnackBar(String message, {
    bool isError = false,
    bool isSuccess = false,
    int duration = 2,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isError)
              const Icon(Icons.error, color: Colors.white)
            else if (isSuccess)
              const Icon(Icons.check_circle, color: Colors.white)
            else
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: isError
            ? AppColors.error
            : isSuccess
                ? AppColors.success
                : AppColors.primary,
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stateManager.dispose();
    super.dispose();
  }
}