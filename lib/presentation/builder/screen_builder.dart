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
  final ScrollController _canvasScrollController = ScrollController();
  double _zoomLevel = 1.0;
  bool _showGrid = true;
  bool _showOutlines = true;

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
          title: const Text('Loading Builder...'),
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
          // Zoom controls
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 2.0);
              });
            },
            tooltip: 'Zoom Out',
          ),
          Text(
            '${(_zoomLevel * 100).toInt()}%',
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 2.0);
              });
            },
            tooltip: 'Zoom In',
          ),
          const SizedBox(width: 8),
          // View options
          IconButton(
            icon: Icon(_showGrid ? Icons.grid_on : Icons.grid_off),
            onPressed: () {
              setState(() {
                _showGrid = !_showGrid;
              });
            },
            tooltip: _showGrid ? 'Hide Grid' : 'Show Grid',
          ),
          IconButton(
            icon: Icon(_showOutlines ? Icons.border_all : Icons.border_clear),
            onPressed: () {
              setState(() {
                _showOutlines = !_showOutlines;
              });
            },
            tooltip: _showOutlines ? 'Hide Outlines' : 'Show Outlines',
          ),
          const SizedBox(width: 8),
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
          // Left sidebar - Enhanced Widget palette
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Widget Tree View Toggle
                Container(
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
                        onPressed: () {
                          _showWidgetTreeDialog(context, builderProvider);
                        },
                        tooltip: 'View Widget Tree',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: WidgetPicker(
                    onWidgetSelected: (widgetData) {
                      _addWidgetToCanvas(widgetData);
                    },
                    screenId: _selectedScreenId,
                  ),
                ),
              ],
            ),
          ),

          // Center - Enhanced Canvas
          Expanded(
            child: Column(
              children: [
                // Screen selector with better UI
                _buildEnhancedScreenSelector(builderProvider),

                // Canvas toolbar
                _buildCanvasToolbar(),

                // Enhanced Canvas
                Expanded(
                  child: _buildEnhancedCanvas(builderProvider),
                ),
              ],
            ),
          ),

          // Right sidebar - Properties panel
          Container(
            width: 320,
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

  Widget _buildEnhancedScreenSelector(BuilderProvider builderProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.phone_android, color: Colors.grey[700]),
          const SizedBox(width: 12),
          const Text(
            'Screen:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: DropdownButton<String>(
                value: _selectedScreenId,
                isExpanded: true,
                underline: const SizedBox(),
                items: builderProvider.screens.map((screen) {
                  return DropdownMenuItem(
                    value: screen.id.toString(),
                    child: Row(
                      children: [
                        if (screen.isHomeScreen)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'HOME',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        if (screen.isHomeScreen) const SizedBox(width: 8),
                        Text(
                          screen.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${screen.routeName})',
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
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              _showAddScreenDialog(context);
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Screen'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
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

  Widget _buildCanvasToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Canvas',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            '${context.watch<BuilderProvider>().widgets.length} widgets',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCanvas(BuilderProvider builderProvider) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAccept: (widgetData) {
        _addWidgetToCanvas(widgetData);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          child: _showGrid
              ? CustomPaint(
                  painter: GridPainter(color: Colors.grey[300]!.withOpacity(0.3)),
                  child: _buildCanvasContent(builderProvider, isHighlighted),
                )
              : _buildCanvasContent(builderProvider, isHighlighted),
        );
      },
    );
  }

  Widget _buildCanvasContent(BuilderProvider builderProvider, bool isHighlighted) {
    return Center(
      child: SingleChildScrollView(
        controller: _canvasScrollController,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Transform.scale(
            scale: _zoomLevel,
            child: Container(
              width: 375, // iPhone width
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isHighlighted ? AppColors.primary : Colors.grey[400]!,
                  width: isHighlighted ? 3 : 2,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: builderProvider.selectedScreen == null
                    ? _buildEmptyScreenState()
                    : _buildEnhancedScreenPreview(builderProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyScreenState() {
    return Container(
      height: 667,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_box_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Select or create a screen',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your app interface',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedScreenPreview(BuilderProvider builderProvider) {
    final screen = builderProvider.selectedScreen!;

    return Container(
      constraints: const BoxConstraints(minHeight: 667),
      child: Column(
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {},
                    ),
                  Expanded(
                    child: Text(
                      screen.appBarTitle ?? screen.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: screen.showBackButton ? TextAlign.left : TextAlign.center,
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
                  ? _buildEnhancedEmptyCanvasState()
                  : _buildVisualWidgetTree(builderProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedEmptyCanvasState() {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAccept: (widgetData) {
        _addWidgetToCanvas(widgetData);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isHighlighted
                  ? AppColors.primary
                  : Colors.grey[300]!,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isHighlighted
                ? AppColors.primary.withOpacity(0.05)
                : Colors.grey[50],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 64,
                  color: isHighlighted
                      ? AppColors.primary
                      : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Drop widgets here',
                  style: TextStyle(
                    color: isHighlighted
                        ? AppColors.primary
                        : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Drag from the widget toolkit',
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

  Widget _buildVisualWidgetTree(BuilderProvider builderProvider) {
    // Group widgets by parent
    final Map<int?, List<AppWidget>> widgetsByParent = {};
    for (var widget in builderProvider.widgets) {
      final parentId = widget.parentWidget;
      widgetsByParent[parentId] ??= [];
      widgetsByParent[parentId]!.add(widget);
    }

    // Sort each group by order
    widgetsByParent.forEach((key, value) {
      value.sort((a, b) => a.order.compareTo(b.order));
    });

    // Build root widgets (no parent)
    final rootWidgets = widgetsByParent[null] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rootWidgets.map((widget) {
          return _buildWidgetNode(widget, widgetsByParent, builderProvider, 0);
        }).toList(),
      ),
    );
  }

  Widget _buildWidgetNode(
    AppWidget widget,
    Map<int?, List<AppWidget>> widgetsByParent,
    BuilderProvider builderProvider,
    int depth,
  ) {
    final isSelected = builderProvider.selectedWidget?.id == widget.id;
    final children = widgetsByParent[widget.id] ?? [];
    final hasChildren = children.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(left: depth * 20.0, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              builderProvider.selectWidget(widget);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : _showOutlines
                          ? Colors.grey[300]!
                          : Colors.transparent,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.white.withOpacity(0.8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  // Widget header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getWidgetColor(widget.widgetType).withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getWidgetIcon(widget.widgetType),
                          size: 18,
                          color: _getWidgetColor(widget.widgetType),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.widgetType,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                  color: _getWidgetColor(widget.widgetType),
                                ),
                              ),
                              if (widget.widgetId != null)
                                Text(
                                  '#${widget.widgetId}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (hasChildren)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${children.length}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, size: 16, color: Colors.grey[600]),
                          onSelected: (value) {
                            switch (value) {
                              case 'delete':
                                _deleteWidget(widget);
                                break;
                              case 'duplicate':
                                _duplicateWidget(widget);
                                break;
                              case 'moveUp':
                                _moveWidgetUp(widget);
                                break;
                              case 'moveDown':
                                _moveWidgetDown(widget);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'duplicate',
                              child: Row(
                                children: [
                                  Icon(Icons.copy, size: 16),
                                  SizedBox(width: 8),
                                  Text('Duplicate'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'moveUp',
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_upward, size: 16),
                                  SizedBox(width: 8),
                                  Text('Move Up'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'moveDown',
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_downward, size: 16),
                                  SizedBox(width: 8),
                                  Text('Move Down'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Widget content preview
                  if (!hasChildren)
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: _buildWidgetPreview(widget),
                    ),
                ],
              ),
            ),
          ),
          // Render children
          if (hasChildren) ...[
            Container(
              margin: const EdgeInsets.only(left: 20, top: 4),
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children.map((child) {
                  return _buildWidgetNode(child, widgetsByParent, builderProvider, depth + 1);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWidgetPreview(AppWidget widget) {
    // Simple preview based on widget type
    switch (widget.widgetType) {
      case 'Text':
        return Text(
          _getPropertyValue(widget, 'text') ?? 'Sample Text',
          style: TextStyle(color: Colors.grey[700]),
        );
      case 'Button':
      case 'ElevatedButton':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _getPropertyValue(widget, 'text') ?? 'Button',
            style: const TextStyle(color: Colors.white),
          ),
        );
      case 'TextField':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _getPropertyValue(widget, 'hintText') ?? 'Enter text...',
            style: TextStyle(color: Colors.grey[500]),
          ),
        );
      case 'Image':
        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Icon(Icons.image, color: Colors.grey),
          ),
        );
      case 'Container':
        return Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              'Container',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      default:
        return const SizedBox(height: 20);
    }
  }

  String? _getPropertyValue(AppWidget widget, String propertyName) {
    if (widget.properties == null) return null;

    try {
      final property = widget.properties!.firstWhere(
        (p) => p.propertyName == propertyName,
      );
      return property.getDisplayValue();
    } catch (e) {
      return null;
    }
  }

  void _showWidgetTreeDialog(BuildContext context, BuilderProvider builderProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          height: 600,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.account_tree, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Widget Tree',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _buildTreeView(builderProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTreeView(BuilderProvider builderProvider) {
    if (builderProvider.widgets.isEmpty) {
      return const Center(
        child: Text('No widgets added yet'),
      );
    }

    // Build tree structure
    final Map<int?, List<AppWidget>> widgetsByParent = {};
    for (var widget in builderProvider.widgets) {
      final parentId = widget.parentWidget;
      widgetsByParent[parentId] ??= [];
      widgetsByParent[parentId]!.add(widget);
    }

    final rootWidgets = widgetsByParent[null] ?? [];

    return ListView(
      children: rootWidgets.map((widget) {
        return _buildTreeNode(widget, widgetsByParent, 0);
      }).toList(),
    );
  }

  Widget _buildTreeNode(
    AppWidget widget,
    Map<int?, List<AppWidget>> widgetsByParent,
    int depth,
  ) {
    final children = widgetsByParent[widget.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 20.0),
          child: Row(
            children: [
              if (children.isNotEmpty)
                Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[600])
              else
                const SizedBox(width: 20),
              Icon(
                _getWidgetIcon(widget.widgetType),
                size: 16,
                color: _getWidgetColor(widget.widgetType),
              ),
              const SizedBox(width: 8),
              Text(
                widget.widgetType,
                style: const TextStyle(fontSize: 14),
              ),
              if (widget.widgetId != null) ...[
                const SizedBox(width: 8),
                Text(
                  '#${widget.widgetId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        ...children.map((child) {
          return _buildTreeNode(child, widgetsByParent, depth + 1);
        }).toList(),
      ],
    );
  }

  Color _getWidgetColor(String widgetType) {
    switch (widgetType) {
      case 'Column':
      case 'Row':
      case 'Stack':
      case 'Container':
        return AppColors.layoutWidget;
      case 'Text':
      case 'Image':
      case 'Icon':
        return AppColors.displayWidget;
      case 'TextField':
      case 'Button':
      case 'ElevatedButton':
      case 'TextButton':
        return AppColors.inputWidget;
      case 'ListView':
      case 'GridView':
        return AppColors.scrollableWidget;
      default:
        return AppColors.primary;
    }
  }

  Future<void> _duplicateWidget(AppWidget widget) async {
    // TODO: Implement widget duplication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Widget duplication coming soon!')),
    );
  }

  // ... Rest of the existing methods remain the same ...
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Screen settings coming soon!')),
    );
  }

  void _showPreviewDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preview coming soon!')),
    );
  }

  void _showCodePreview(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code preview coming soon!')),
    );
  }

  void _saveChanges() {
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

  @override
  void dispose() {
    _canvasScrollController.dispose();
    super.dispose();
  }
}

// Custom painter for grid pattern
class GridPainter extends CustomPainter {
  final Color color;
  final double gridSize;

  GridPainter({required this.color, this.gridSize = 20.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.gridSize != gridSize;
  }
}