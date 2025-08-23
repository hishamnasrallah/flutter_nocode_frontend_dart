// lib/presentation/builder/widget_picker.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/builder_provider.dart';
import '../../core/constants/app_colors.dart';

class WidgetPicker extends StatefulWidget {
  final Function(Map<String, dynamic>) onWidgetSelected;
  final String? screenId;

  const WidgetPicker({
    super.key,
    required this.onWidgetSelected,
    this.screenId,
  });

  @override
  State<WidgetPicker> createState() => _WidgetPickerState();
}

class _WidgetPickerState extends State<WidgetPicker> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  bool _isGridView = false;

  final Map<String, List<Map<String, dynamic>>> _widgetCategories = {
    'Layout': [
      {
        'name': 'Column',
        'type': 'Column',
        'icon': 'view_agenda',
        'description': 'Vertical layout',
        'properties': ['mainAxisAlignment', 'crossAxisAlignment'],
        'canHaveChildren': true,
      },
      {
        'name': 'Row',
        'type': 'Row',
        'icon': 'view_week',
        'description': 'Horizontal layout',
        'properties': ['mainAxisAlignment', 'crossAxisAlignment'],
        'canHaveChildren': true,
      },
      {
        'name': 'Container',
        'type': 'Container',
        'icon': 'crop_square',
        'description': 'Box with decoration',
        'properties': ['width', 'height', 'padding', 'margin', 'color'],
        'canHaveChildren': true,
      },
      {
        'name': 'Stack',
        'type': 'Stack',
        'icon': 'layers',
        'description': 'Overlay widgets',
        'properties': ['alignment', 'fit'],
        'canHaveChildren': true,
      },
      {
        'name': 'Center',
        'type': 'Center',
        'icon': 'center_focus_strong',
        'description': 'Center child widget',
        'properties': [],
        'canHaveChildren': true,
      },
      {
        'name': 'Padding',
        'type': 'Padding',
        'icon': 'padding',
        'description': 'Add padding',
        'properties': ['padding'],
        'canHaveChildren': true,
      },
      {
        'name': 'Expanded',
        'type': 'Expanded',
        'icon': 'unfold_more',
        'description': 'Expand in flex',
        'properties': ['flex'],
        'canHaveChildren': true,
      },
      {
        'name': 'SizedBox',
        'type': 'SizedBox',
        'icon': 'aspect_ratio',
        'description': 'Fixed size box',
        'properties': ['width', 'height'],
        'canHaveChildren': true,
      },
    ],
    'Display': [
      {
        'name': 'Text',
        'type': 'Text',
        'icon': 'text_fields',
        'description': 'Display text',
        'properties': ['text', 'fontSize', 'fontWeight', 'color', 'textAlign'],
        'canHaveChildren': false,
      },
      {
        'name': 'Image',
        'type': 'Image',
        'icon': 'image',
        'description': 'Display image',
        'properties': ['src', 'width', 'height', 'fit'],
        'canHaveChildren': false,
      },
      {
        'name': 'Icon',
        'type': 'Icon',
        'icon': 'emoji_emotions',
        'description': 'Material icon',
        'properties': ['icon', 'size', 'color'],
        'canHaveChildren': false,
      },
      {
        'name': 'Card',
        'type': 'Card',
        'icon': 'credit_card',
        'description': 'Material card',
        'properties': ['elevation', 'color', 'shape'],
        'canHaveChildren': true,
      },
      {
        'name': 'Divider',
        'type': 'Divider',
        'icon': 'remove',
        'description': 'Horizontal line',
        'properties': ['height', 'thickness', 'color'],
        'canHaveChildren': false,
      },
      {
        'name': 'Chip',
        'type': 'Chip',
        'icon': 'label',
        'description': 'Compact element',
        'properties': ['label', 'avatar', 'deleteIcon'],
        'canHaveChildren': false,
      },
    ],
    'Input': [
      {
        'name': 'TextField',
        'type': 'TextField',
        'icon': 'input',
        'description': 'Text input field',
        'properties': ['labelText', 'hintText', 'helperText', 'obscureText'],
        'canHaveChildren': false,
      },
      {
        'name': 'ElevatedButton',
        'type': 'ElevatedButton',
        'icon': 'smart_button',
        'description': 'Raised button',
        'properties': ['text', 'onPressed', 'backgroundColor'],
        'canHaveChildren': false,
      },
      {
        'name': 'TextButton',
        'type': 'TextButton',
        'icon': 'touch_app',
        'description': 'Flat text button',
        'properties': ['text', 'onPressed', 'textColor'],
        'canHaveChildren': false,
      },
      {
        'name': 'IconButton',
        'type': 'IconButton',
        'icon': 'touch_app',
        'description': 'Icon button',
        'properties': ['icon', 'onPressed', 'color', 'size'],
        'canHaveChildren': false,
      },
      {
        'name': 'Switch',
        'type': 'Switch',
        'icon': 'toggle_on',
        'description': 'Toggle switch',
        'properties': ['value', 'onChanged', 'activeColor'],
        'canHaveChildren': false,
      },
      {
        'name': 'Checkbox',
        'type': 'Checkbox',
        'icon': 'check_box',
        'description': 'Checkbox input',
        'properties': ['value', 'onChanged', 'activeColor'],
        'canHaveChildren': false,
      },
      {
        'name': 'Radio',
        'type': 'Radio',
        'icon': 'radio_button_checked',
        'description': 'Radio button',
        'properties': ['value', 'groupValue', 'onChanged'],
        'canHaveChildren': false,
      },
      {
        'name': 'Slider',
        'type': 'Slider',
        'icon': 'tune',
        'description': 'Value slider',
        'properties': ['value', 'min', 'max', 'onChanged'],
        'canHaveChildren': false,
      },
      {
        'name': 'FloatingActionButton',
        'type': 'FloatingActionButton',
        'icon': 'add_circle',
        'description': 'FAB button',
        'properties': ['icon', 'onPressed', 'backgroundColor'],
        'canHaveChildren': false,
      },
    ],
    'Scrollable': [
      {
        'name': 'ListView',
        'type': 'ListView',
        'icon': 'list',
        'description': 'Scrollable list',
        'properties': ['scrollDirection', 'shrinkWrap', 'itemCount'],
        'canHaveChildren': true,
      },
      {
        'name': 'GridView',
        'type': 'GridView',
        'icon': 'grid_on',
        'description': 'Scrollable grid',
        'properties': ['crossAxisCount', 'childAspectRatio', 'spacing'],
        'canHaveChildren': true,
      },
      {
        'name': 'SingleChildScrollView',
        'type': 'SingleChildScrollView',
        'icon': 'swap_vert',
        'description': 'Scrollable container',
        'properties': ['scrollDirection', 'padding'],
        'canHaveChildren': true,
      },
      {
        'name': 'PageView',
        'type': 'PageView',
        'icon': 'view_carousel',
        'description': 'Swipeable pages',
        'properties': ['scrollDirection', 'pageSnapping'],
        'canHaveChildren': true,
      },
    ],
    'Navigation': [
      {
        'name': 'AppBar',
        'type': 'AppBar',
        'icon': 'web_asset',
        'description': 'Top app bar',
        'properties': ['title', 'backgroundColor', 'elevation'],
        'canHaveChildren': false,
      },
      {
        'name': 'BottomNavigationBar',
        'type': 'BottomNavigationBar',
        'icon': 'dashboard',
        'description': 'Bottom navigation',
        'properties': ['items', 'currentIndex', 'onTap'],
        'canHaveChildren': false,
      },
      {
        'name': 'Drawer',
        'type': 'Drawer',
        'icon': 'menu',
        'description': 'Side drawer',
        'properties': ['width', 'elevation'],
        'canHaveChildren': true,
      },
      {
        'name': 'TabBar',
        'type': 'TabBar',
        'icon': 'tab',
        'description': 'Tab navigation',
        'properties': ['tabs', 'controller'],
        'canHaveChildren': false,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _widgetCategories.length, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar with enhanced UI
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search widgets...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[600]),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                            onPressed: () {
                              _searchController.clear();
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            _isGridView ? Icons.view_list : Icons.grid_view,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = !_isGridView;
                            });
                          },
                          tooltip: _isGridView ? 'List View' : 'Grid View',
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),

        // Category tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            tabs: _widgetCategories.keys.map((category) {
              return Tab(
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(category), size: 18),
                    const SizedBox(width: 6),
                    Text(category),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Widget list
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _widgetCategories.entries.map((entry) {
              final widgets = _filterWidgets(entry.value);

              if (widgets.isEmpty) {
                return _buildEmptyState();
              }

              return _isGridView
                  ? _buildGridView(widgets, _getCategoryColor(entry.key))
                  : _buildListView(widgets, _getCategoryColor(entry.key));
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _filterWidgets(List<Map<String, dynamic>> widgets) {
    if (_searchQuery.isEmpty) return widgets;

    return widgets.where((widget) {
      final name = widget['name'].toString().toLowerCase();
      final description = widget['description'].toString().toLowerCase();
      final properties = (widget['properties'] as List).join(' ').toLowerCase();

      return name.contains(_searchQuery) ||
             description.contains(_searchQuery) ||
             properties.contains(_searchQuery);
    }).toList();
  }

  Widget _buildGridView(List<Map<String, dynamic>> widgets, Color categoryColor) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        final widget = widgets[index];
        return _buildGridItem(widget, categoryColor);
      },
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> widgets, Color categoryColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        final widget = widgets[index];
        return _buildEnhancedWidgetItem(widget, categoryColor);
      },
    );
  }

  Widget _buildGridItem(Map<String, dynamic> widget, Color categoryColor) {
    return Draggable<Map<String, dynamic>>(
      data: widget,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          height: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [categoryColor, categoryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconData(widget['icon']),
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                widget['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildGridCard(widget, categoryColor),
      ),
      child: _buildGridCard(widget, categoryColor),
    );
  }

  Widget _buildGridCard(Map<String, dynamic> widget, Color categoryColor) {
    final canHaveChildren = widget['canHaveChildren'] ?? false;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          this.widget.onWidgetSelected(widget);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                categoryColor.withOpacity(0.05),
                categoryColor.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(widget['icon']),
                  size: 26,
                  color: categoryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget['name'],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget['description'],
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (canHaveChildren) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Container',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedWidgetItem(Map<String, dynamic> widget, Color categoryColor) {
    final canHaveChildren = widget['canHaveChildren'] ?? false;

    return Draggable<Map<String, dynamic>>(
      data: widget,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [categoryColor, categoryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconData(widget['icon']),
                size: 24,
                color: Colors.white,
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
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildEnhancedWidgetTile(widget, categoryColor),
      ),
      child: _buildEnhancedWidgetTile(widget, categoryColor),
    );
  }

  Widget _buildEnhancedWidgetTile(Map<String, dynamic> widget, Color categoryColor) {
    final canHaveChildren = widget['canHaveChildren'] ?? false;
    final properties = widget['properties'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        elevation: 1,
        child: InkWell(
          onTap: () {
            this.widget.onWidgetSelected(widget);
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: categoryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor.withOpacity(0.15),
                        categoryColor.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconData(widget['icon']),
                    size: 24,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (canHaveChildren)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Container',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (properties.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: properties.take(3).map((prop) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                prop,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // Drag handle
                Icon(
                  Icons.drag_indicator,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
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
            size: 64,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Layout':
        return Icons.dashboard_outlined;
      case 'Display':
        return Icons.visibility_outlined;
      case 'Input':
        return Icons.keyboard_outlined;
      case 'Scrollable':
        return Icons.swap_vert_outlined;
      case 'Navigation':
        return Icons.menu_outlined;
      default:
        return Icons.widgets_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Layout':
        return AppColors.layoutWidget;
      case 'Display':
        return AppColors.displayWidget;
      case 'Input':
        return AppColors.inputWidget;
      case 'Scrollable':
        return AppColors.scrollableWidget;
      case 'Navigation':
        return AppColors.navigationWidget;
      default:
        return AppColors.primary;
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'view_agenda':
        return Icons.view_agenda;
      case 'view_week':
        return Icons.view_week;
      case 'crop_square':
        return Icons.crop_square;
      case 'layers':
        return Icons.layers;
      case 'center_focus_strong':
        return Icons.center_focus_strong;
      case 'padding':
        return Icons.padding;
      case 'unfold_more':
        return Icons.unfold_more;
      case 'aspect_ratio':
        return Icons.aspect_ratio;
      case 'text_fields':
        return Icons.text_fields;
      case 'image':
        return Icons.image;
      case 'emoji_emotions':
        return Icons.emoji_emotions;
      case 'credit_card':
        return Icons.credit_card;
      case 'remove':
        return Icons.remove;
      case 'label':
        return Icons.label;
      case 'input':
        return Icons.input;
      case 'smart_button':
        return Icons.smart_button;
      case 'touch_app':
        return Icons.touch_app;
      case 'toggle_on':
        return Icons.toggle_on;
      case 'check_box':
        return Icons.check_box;
      case 'radio_button_checked':
        return Icons.radio_button_checked;
      case 'tune':
        return Icons.tune;
      case 'add_circle':
        return Icons.add_circle;
      case 'list':
        return Icons.list;
      case 'grid_on':
        return Icons.grid_on;
      case 'swap_vert':
        return Icons.swap_vert;
      case 'view_carousel':
        return Icons.view_carousel;
      case 'web_asset':
        return Icons.web_asset;
      case 'dashboard':
        return Icons.dashboard;
      case 'menu':
        return Icons.menu;
      case 'tab':
        return Icons.tab;
      default:
        return Icons.widgets;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}