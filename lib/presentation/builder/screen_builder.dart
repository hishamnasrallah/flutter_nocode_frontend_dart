
// lib/presentation/builder/screen_builder.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/builder_provider.dart';
import '../../providers/application_provider.dart';
import '../../core/constants/app_colors.dart';

class ScreenBuilder extends StatefulWidget {
  final String applicationId;

  const ScreenBuilder({super.key, required this.applicationId});

  @override
  State<ScreenBuilder> createState() => _ScreenBuilderState();
}

class _ScreenBuilderState extends State<ScreenBuilder> {
  String? _selectedScreenId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final builderProvider = context.read<BuilderProvider>();
    await builderProvider.fetchScreens(widget.applicationId);

    if (builderProvider.screens.isNotEmpty) {
      setState(() {
        _selectedScreenId = builderProvider.screens.first.id.toString();
      });
      await builderProvider.fetchScreenDetail(_selectedScreenId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final builderProvider = context.watch<BuilderProvider>();
    final applicationProvider = context.watch<ApplicationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Builder - ${applicationProvider.selectedApplication?.name ?? 'App'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: () {
              // TODO: Show preview
            },
            tooltip: 'Preview',
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {
              // TODO: Show generated code
            },
            tooltip: 'View Code',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // TODO: Save changes
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
            child: _buildWidgetPalette(builderProvider),
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
            child: _buildPropertiesPanel(builderProvider),
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
              // TODO: Screen settings
            },
            tooltip: 'Screen Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetPalette(BuilderProvider builderProvider) {
    final widgetTypes = builderProvider.widgetTypes ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Widget Palette',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildWidgetCategory('Layout', widgetTypes['layout'], AppColors.layoutWidget),
              _buildWidgetCategory('Display', widgetTypes['display'], AppColors.displayWidget),
              _buildWidgetCategory('Input', widgetTypes['input'], AppColors.inputWidget),
              _buildWidgetCategory('Scrollable', widgetTypes['scrollable'], AppColors.scrollableWidget),
              _buildWidgetCategory('Navigation', widgetTypes['navigation'], AppColors.navigationWidget),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetCategory(String title, List<dynamic>? widgets, Color color) {
    if (widgets == null || widgets.isEmpty) return const SizedBox();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        leading: Container(
          width: 4,
          height: 24,
          color: color,
        ),
        initiallyExpanded: true,
        children: widgets.map((widget) {
          return Draggable<Map<String, dynamic>>(
            data: widget,
            feedback: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget['name'],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            child: ListTile(
              dense: true,
              leading: Icon(
                _getIconData(widget['icon']),
                size: 20,
                color: color,
              ),
              title: Text(
                widget['name'],
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                widget['description'],
                style: const TextStyle(fontSize: 11),
              ),
              onTap: () {
                _addWidget(widget);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCanvas(BuilderProvider builderProvider) {
    return DragTarget<Map<String, dynamic>>(
      onAccept: (widget) {
        _addWidget(widget);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: Colors.grey[100],
          child: Center(
            child: Container(
              width: 375, // iPhone width
              height: 667, // iPhone height
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[400]!),
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
                ? Center(
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
                      ],
                    ),
                  )
                : _buildWidgetTree(builderProvider.widgets),
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetTree(List<dynamic> widgets) {
    // Simplified widget tree rendering
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        final widget = widgets[index];
        return _buildWidgetPreview(widget);
      },
    );
  }

  Widget _buildWidgetPreview(dynamic widget) {
    // Simplified widget preview rendering
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getWidgetIcon(widget.widgetType),
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(widget.widgetType),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings, size: 16),
            onPressed: () {
              // Select widget for properties editing
              context.read<BuilderProvider>().selectWidget(widget);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 16),
            onPressed: () {
              // Delete widget
              context.read<BuilderProvider>().deleteWidget(widget.id.toString());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesPanel(BuilderProvider builderProvider) {
    final selectedWidget = builderProvider.selectedWidget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Properties',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (selectedWidget == null)
          const Expanded(
            child: Center(
              child: Text(
                'Select a widget to edit properties',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  selectedWidget.widgetType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Properties would be dynamically generated based on widget type
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Widget ID',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: selectedWidget.widgetId),
                ),
                const SizedBox(height: 16),
                // Add more property fields based on widget type
              ],
            ),
          ),
      ],
    );
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

  void _addWidget(Map<String, dynamic> widgetData) async {
    if (_selectedScreenId == null) return;

    final builderProvider = context.read<BuilderProvider>();
    await builderProvider.addWidget(
      screenId: _selectedScreenId!,
      widgetType: widgetData['type'],
    );

    // Refresh screen
    await builderProvider.fetchScreenDetail(_selectedScreenId!);
  }

  IconData _getIconData(String? iconName) {
    // Map icon names to IconData
    // This is a simplified version - you might want to create a comprehensive mapping
    switch (iconName) {
      case 'view_column':
        return Icons.view_column;
      case 'view_stream':
        return Icons.view_stream;
      case 'crop_square':
        return Icons.crop_square;
      default:
        return Icons.widgets;
    }
  }

  IconData _getWidgetIcon(String widgetType) {
    // Map widget types to icons
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
        return Icons.smart_button;
      default:
        return Icons.widgets;
    }
  }
}