// lib/presentation/builder/components/widget_palette/simplified_widget_picker.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SimplifiedWidgetPicker extends StatefulWidget {
  final Function(Map<String, dynamic>) onWidgetSelected;
  final String? screenId;

  const SimplifiedWidgetPicker({
    super.key,
    required this.onWidgetSelected,
    this.screenId,
  });

  @override
  State<SimplifiedWidgetPicker> createState() => _SimplifiedWidgetPickerState();
}

class _SimplifiedWidgetPickerState extends State<SimplifiedWidgetPicker>
    with SingleTickerProviderStateMixin {

  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  String? _hoveredWidget;

  // Simplified widget categories for non-technical users
  final Map<String, List<Map<String, dynamic>>> _widgetCategories = {
    '🎨 Basic': [
      {
        'name': 'Text',
        'type': 'Text',
        'icon': Icons.text_fields,
        'description': 'Add text to your screen',
        'preview': 'Hello World',
      },
      {
        'name': 'Button',
        'type': 'ElevatedButton',
        'icon': Icons.smart_button,
        'description': 'A clickable button',
        'preview': 'Click Me',
      },
      {
        'name': 'Image',
        'type': 'Image',
        'icon': Icons.image,
        'description': 'Display an image',
        'preview': null,
      },
      {
        'name': 'Icon',
        'type': 'Icon',
        'icon': Icons.star,
        'description': 'Add an icon',
        'preview': null,
      },
    ],
    '📦 Containers': [
      {
        'name': 'Box',
        'type': 'Container',
        'icon': Icons.crop_square,
        'description': 'A container for other widgets',
        'preview': null,
      },
      {
        'name': 'Card',
        'type': 'Card',
        'icon': Icons.credit_card,
        'description': 'A material design card',
        'preview': null,
      },
      {
        'name': 'Column',
        'type': 'Column',
        'icon': Icons.view_agenda,
        'description': 'Stack widgets vertically',
        'preview': null,
      },
      {
        'name': 'Row',
        'type': 'Row',
        'icon': Icons.view_week,
        'description': 'Arrange widgets horizontally',
        'preview': null,
      },
    ],
    '✏️ Input': [
      {
        'name': 'Text Field',
        'type': 'TextField',
        'icon': Icons.input,
        'description': 'Let users type text',
        'preview': 'Enter text...',
      },
      {
        'name': 'Switch',
        'type': 'Switch',
        'icon': Icons.toggle_on,
        'description': 'On/Off toggle',
        'preview': null,
      },
      {
        'name': 'Checkbox',
        'type': 'Checkbox',
        'icon': Icons.check_box,
        'description': 'Multiple choice selection',
        'preview': null,
      },
      {
        'name': 'Slider',
        'type': 'Slider',
        'icon': Icons.tune,
        'description': 'Select a value from range',
        'preview': null,
      },
    ],
    '📜 Lists': [
      {
        'name': 'List',
        'type': 'ListView',
        'icon': Icons.list,
        'description': 'Scrollable list of items',
        'preview': null,
      },
      {
        'name': 'Grid',
        'type': 'GridView',
        'icon': Icons.grid_on,
        'description': 'Grid of items',
        'preview': null,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _widgetCategories.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildCategoryTabs(),
        Expanded(
          child: _buildWidgetList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.widgets, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Widget Toolkit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Drag and drop to add',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, size: 20),
            onPressed: _showHelp,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search widgets...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value.toLowerCase());
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: _widgetCategories.keys.map((category) {
          return Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(category),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWidgetList() {
    return TabBarView(
      controller: _tabController,
      children: _widgetCategories.entries.map((entry) {
        final widgets = _filterWidgets(entry.value);

        if (widgets.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: widgets.length,
          itemBuilder: (context, index) {
            return _buildWidgetTile(widgets[index]);
          },
        );
      }).toList(),
    );
  }

  Widget _buildWidgetTile(Map<String, dynamic> widget) {
    final isHovered = _hoveredWidget == widget['type'];

    return Draggable<Map<String, dynamic>>(
      data: widget,
      feedback: _buildDragFeedback(widget),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTileContent(widget, false),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredWidget = widget['type']),
        onExit: (_) => setState(() => _hoveredWidget = null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildTileContent(widget, isHovered),
        ),
      ),
    );
  }

  Widget _buildTileContent(Map<String, dynamic> widget, bool isHovered) {
    return Material(
      elevation: isHovered ? 4 : 1,
      borderRadius: BorderRadius.circular(12),
      color: isHovered ? AppColors.primary.withOpacity(0.05) : Colors.white,
      child: InkWell(
        onTap: () => widget.onWidgetSelected(widget),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.grey[200]!,
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon with background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget['icon'],
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Widget info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (widget['preview'] != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget['preview'],
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Drag indicator
              Icon(
                Icons.drag_indicator,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragFeedback(Map<String, dynamic> widget) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget['icon'],
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              widget['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No widgets found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterWidgets(List<Map<String, dynamic>> widgets) {
    if (_searchQuery.isEmpty) return widgets;

    return widgets.where((widget) {
      final name = widget['name'].toString().toLowerCase();
      final description = widget['description'].toString().toLowerCase();
      return name.contains(_searchQuery) || description.contains(_searchQuery);
    }).toList();
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('How to Use Widgets'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              Icons.touch_app,
              'Drag & Drop',
              'Drag any widget from this panel and drop it on your screen',
            ),
            _buildHelpItem(
              Icons.layers,
              'Containers',
              'Use Column, Row, or Box to organize other widgets',
            ),
            _buildHelpItem(
              Icons.edit,
              'Customize',
              'Click any widget on the canvas to edit its properties',
            ),
          ],
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

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

extension on Map<String, dynamic> {
  void onWidgetSelected(Map<String, dynamic> widget) {}
}