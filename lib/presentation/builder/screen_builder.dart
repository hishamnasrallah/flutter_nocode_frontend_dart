// lib/presentation/builder/screen_builder.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/builder_provider.dart';
import '../../providers/application_provider.dart';
import '../../core/constants/app_colors.dart';
import 'widget_picker.dart';
import 'property_editor.dart';
import '../../data/models/app_widget.dart';

class ScreenBuilder extends StatefulWidget {
  final String applicationId;

  const ScreenBuilder({super.key, required this.applicationId});

  @override
  State<ScreenBuilder> createState() => _ScreenBuilderState();
}

class _ScreenBuilderState extends State<ScreenBuilder> {
  String? _selectedScreenId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final builderProvider = context.read<BuilderProvider>();
    await builderProvider.fetchScreens(widget.applicationId);

    if (builderProvider.screens.isNotEmpty && mounted) {
      setState(() {
        _selectedScreenId = builderProvider.screens.first.id.toString();
        _isInitialized = true;
      });
      await builderProvider.fetchScreenDetail(_selectedScreenId!);
      await builderProvider.fetchWidgetsForScreen(_selectedScreenId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final builderProvider = context.watch<BuilderProvider>();
    final applicationProvider = context.watch<ApplicationProvider>();

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading Builder...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Builder - ${applicationProvider.selectedApplication?.name ?? 'App'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadData();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: () {
              _showPreviewDialog(context);
            },
            tooltip: 'Preview',
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {
              _showCodePreview(context);
            },
            tooltip: 'View Code',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveChanges();
            },
            tooltip: 'Save',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar - Widget palette
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: WidgetPicker(
              onWidgetSelected: (widgetData) {
                _addWidgetToCanvas(widgetData);
              },
              screenId: _selectedScreenId,
            ),
          ),

          // Center - Canvas/Preview
          Expanded(
            child: Column(
              children: [
                // Screen selector
                _buildScreenSelector(builderProvider),

                // Canvas
                Expanded(
                  child: _buildCanvas(builderProvider),
                ),
              ],
            ),
          ),

          // Right sidebar - Properties panel
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                left: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: PropertyEditor(
              widget: builderProvider.selectedWidget,
              onPropertyChanged: (propertyName, value) {
                _updateWidgetProperty(propertyName, value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenSelector(BuilderProvider builderProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Screen:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedScreenId,
              isExpanded: true,
              items: builderProvider.screens.map((screen) {
                return DropdownMenuItem(
                  value: screen.id.toString(),
                  child: Row(
                    children: [
                      if (screen.isHomeScreen)
                        const Icon(Icons.home, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(screen.name),
                      const SizedBox(width: 8),
                      Text(
                        screen.routeName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _selectedScreenId = value;
                  });
                  await builderProvider.fetchScreenDetail(value);
                  await builderProvider.fetchWidgetsForScreen(value);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddScreenDialog(context);
            },
            tooltip: 'Add Screen',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showScreenSettingsDialog(context);
            },
            tooltip: 'Screen Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(BuilderProvider builderProvider) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAccept: (widgetData) {
        _addWidgetToCanvas(widgetData);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          color: Colors.grey[100],
          child: Center(
            child: Container(
              width: 375, // iPhone width
              height: 667, // iPhone height
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isHighlighted ? AppColors.primary : Colors.grey[400]!,
                  width: isHighlighted ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: builderProvider.selectedScreen == null
                    ? const Center(
                        child: Text(
                          'Select or create a screen',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : _buildScreenPreview(builderProvider),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScreenPreview(BuilderProvider builderProvider) {
    final screen = builderProvider.selectedScreen!;

    return Column(
      children: [
        if (screen.showAppBar)
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (screen.showBackButton)
                  const IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: null,
                  ),
                Expanded(
                  child: Text(
                    screen.appBarTitle ?? screen.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (screen.showBackButton) const SizedBox(width: 48),
              ],
            ),
          ),
        Expanded(
          child: Container(
            color: screen.backgroundColor != null
                ? Color(int.parse(screen.backgroundColor!.replaceAll('#', '0xFF')))
                : Colors.white,
            child: builderProvider.widgets.isEmpty
                ? _buildEmptyCanvasState()
                : _buildWidgetTreeView(builderProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCanvasState() {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAccept: (widgetData) {
        _addWidgetToCanvas(widgetData);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            border: isHighlighted
                ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 2)
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.widgets_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Drag widgets here',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'or click a widget from the palette',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWidgetTreeView(BuilderProvider builderProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: builderProvider.widgets.map((widget) {
          return _buildWidgetItem(widget, builderProvider);
        }).toList(),
      ),
    );
  }

  Widget _buildWidgetItem(AppWidget widget, BuilderProvider builderProvider) {
    final isSelected = builderProvider.selectedWidget?.id == widget.id;

    return GestureDetector(
      onTap: () {
        builderProvider.selectWidget(widget);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              _getWidgetIcon(widget.widgetType),
              size: 20,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.widgetType,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (widget.widgetId != null)
                    Text(
                      'ID: ${widget.widgetId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_upward, size: 16),
              onPressed: () {
                _moveWidgetUp(widget);
              },
              tooltip: 'Move Up',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward, size: 16),
              onPressed: () {
                _moveWidgetDown(widget);
              },
              tooltip: 'Move Down',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 16),
              onPressed: () {
                _deleteWidget(widget);
              },
              tooltip: 'Delete',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addWidgetToCanvas(Map<String, dynamic> widgetData) async {
    if (_selectedScreenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a screen first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final builderProvider = context.read<BuilderProvider>();

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Adding widget...'),
        duration: Duration(seconds: 1),
      ),
    );

    final success = await builderProvider.addWidget(
      screenId: _selectedScreenId!,
      widgetType: widgetData['type'] ?? widgetData['name'],
    );

    if (success != null) {
      // Refresh the widgets list
      await builderProvider.fetchWidgetsForScreen(_selectedScreenId!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Widget added successfully'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add widget: ${builderProvider.error}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteWidget(AppWidget widget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Widget'),
        content: Text('Are you sure you want to delete this ${widget.widgetType} widget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final builderProvider = context.read<BuilderProvider>();
      final success = await builderProvider.deleteWidget(widget.id.toString());

      if (success) {
        await builderProvider.fetchWidgetsForScreen(_selectedScreenId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Widget deleted'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _moveWidgetUp(AppWidget widget) async {
    final builderProvider = context.read<BuilderProvider>();
    if (widget.order > 0) {
      await builderProvider.reorderWidget(widget.id.toString(), widget.order - 1);
      await builderProvider.fetchWidgetsForScreen(_selectedScreenId!);
    }
  }

  Future<void> _moveWidgetDown(AppWidget widget) async {
    final builderProvider = context.read<BuilderProvider>();
    await builderProvider.reorderWidget(widget.id.toString(), widget.order + 1);
    await builderProvider.fetchWidgetsForScreen(_selectedScreenId!);
  }

  void _updateWidgetProperty(String propertyName, dynamic value) {
    final builderProvider = context.read<BuilderProvider>();
    if (builderProvider.selectedWidget != null) {
      builderProvider.updateWidgetProperty(
        widgetId: builderProvider.selectedWidget!.id.toString(),
        propertyName: propertyName,
        propertyType: _getPropertyType(value),
        value: value,
      );
    }
  }

  String _getPropertyType(dynamic value) {
    if (value is String) return 'string';
    if (value is int) return 'integer';
    if (value is double) return 'decimal';
    if (value is bool) return 'boolean';
    if (value is Color) return 'color';
    return 'string';
  }

  void _showAddScreenDialog(BuildContext context) {
    final nameController = TextEditingController();
    final routeController = TextEditingController();
    bool isHomeScreen = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Screen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Screen Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: routeController,
                decoration: const InputDecoration(
                  labelText: 'Route Path',
                  border: OutlineInputBorder(),
                  hintText: '/screen-name',
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Set as Home Screen'),
                value: isHomeScreen,
                onChanged: (value) {
                  setState(() {
                    isHomeScreen = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final builderProvider = context.read<BuilderProvider>();
                await builderProvider.createScreen(
                  applicationId: widget.applicationId,
                  name: nameController.text,
                  routeName: routeController.text,
                  isHomeScreen: isHomeScreen,
                );
                Navigator.pop(context);
                _loadData();
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showScreenSettingsDialog(BuildContext context) {
    // TODO: Implement screen settings dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Screen settings coming soon!')),
    );
  }

  void _showPreviewDialog(BuildContext context) {
    // TODO: Implement preview dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preview coming soon!')),
    );
  }

  void _showCodePreview(BuildContext context) {
    // TODO: Implement code preview
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code preview coming soon!')),
    );
  }

  void _saveChanges() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  IconData _getWidgetIcon(String widgetType) {
    switch (widgetType) {
      case 'Column':
        return Icons.view_agenda;
      case 'Row':
        return Icons.view_week;
      case 'Container':
        return Icons.crop_square;
      case 'Text':
        return Icons.text_fields;
      case 'Image':
        return Icons.image;
      case 'Button':
      case 'ElevatedButton':
      case 'TextButton':
        return Icons.smart_button;
      case 'TextField':
        return Icons.input;
      case 'ListView':
        return Icons.list;
      case 'GridView':
        return Icons.grid_on;
      case 'Card':
        return Icons.credit_card;
      case 'Stack':
        return Icons.layers;
      case 'Padding':
        return Icons.padding;
      case 'Center':
        return Icons.center_focus_strong;
      default:
        return Icons.widgets;
    }
  }
}