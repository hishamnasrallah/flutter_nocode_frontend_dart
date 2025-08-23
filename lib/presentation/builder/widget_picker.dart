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

class _WidgetPickerState extends State<WidgetPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final builderProvider = context.watch<BuilderProvider>();
    final widgetTypes = builderProvider.widgetTypes ?? {};

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Widget Palette',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search widgets...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Category filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('all', 'All', Icons.widgets),
                    _buildCategoryChip('layout', 'Layout', Icons.dashboard),
                    _buildCategoryChip('display', 'Display', Icons.visibility),
                    _buildCategoryChip('input', 'Input', Icons.input),
                    _buildCategoryChip('scrollable', 'Scrollable', Icons.swap_vert),
                    _buildCategoryChip('navigation', 'Navigation', Icons.menu),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Widget list
        Expanded(
          child: _buildWidgetList(widgetTypes),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    final color = _getCategoryColor(category);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : 'all';
          });
        },
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildWidgetList(Map<String, dynamic> widgetTypes) {
    List<Widget> allWidgets = [];

    // Filter widgets based on category and search
    widgetTypes.forEach((category, widgets) {
      if (_selectedCategory != 'all' && _selectedCategory != category) {
        return;
      }

      final categoryColor = _getCategoryColor(category);
      final filteredWidgets = (widgets as List).where((widget) {
        if (_searchQuery.isEmpty) return true;
        return widget['name'].toString().toLowerCase().contains(_searchQuery) ||
               widget['description'].toString().toLowerCase().contains(_searchQuery);
      }).toList();

      if (filteredWidgets.isNotEmpty) {
        allWidgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getCategoryTitle(category),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ),
        );

        for (var widget in filteredWidgets) {
          allWidgets.add(_buildWidgetItem(widget, categoryColor));
        }
      }
    });

    if (allWidgets.isEmpty) {
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
              'Try adjusting your search or filter',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: allWidgets,
    );
  }

  Widget _buildWidgetItem(Map<String, dynamic> widget, Color categoryColor) {
    return Draggable<Map<String, dynamic>>(
      data: widget,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: categoryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconData(widget['icon']),
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                widget['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildWidgetTile(widget, categoryColor),
      ),
      child: _buildWidgetTile(widget, categoryColor),
    );
  }

  Widget _buildWidgetTile(Map<String, dynamic> widget, Color categoryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 1,
        child: InkWell(
          onTap: () {
            this.widget.onWidgetSelected(widget);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconData(widget['icon']),
                    size: 20,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget['properties'] != null &&
                          (widget['properties'] as List).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: (widget['properties'] as List)
                              .take(3)
                              .map((prop) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      prop,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'layout':
        return AppColors.layoutWidget;
      case 'display':
        return AppColors.displayWidget;
      case 'input':
        return AppColors.inputWidget;
      case 'scrollable':
        return AppColors.scrollableWidget;
      case 'navigation':
        return AppColors.navigationWidget;
      default:
        return AppColors.primary;
    }
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'layout':
        return 'Layout Widgets';
      case 'display':
        return 'Display Widgets';
      case 'input':
        return 'Input Widgets';
      case 'scrollable':
        return 'Scrollable Widgets';
      case 'navigation':
        return 'Navigation Widgets';
      case 'special':
        return 'Special Widgets';
      default:
        return category;
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'view_column':
        return Icons.view_column;
      case 'view_stream':
        return Icons.view_stream;
      case 'crop_square':
        return Icons.crop_square;
      case 'layers':
        return Icons.layers;
      case 'format_indent_increase':
        return Icons.format_indent_increase;
      case 'format_align_center':
        return Icons.format_align_center;
      case 'unfold_more':
        return Icons.unfold_more;
      case 'unfold_less':
        return Icons.unfold_less;
      case 'wrap_text':
        return Icons.wrap_text;
      case 'gps_fixed':
        return Icons.gps_fixed;
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
      case 'list':
        return Icons.list;
      case 'input':
        return Icons.input;
      case 'smart_button':
        return Icons.smart_button;
      case 'touch_app':
        return Icons.touch_app;
      case 'add_circle':
        return Icons.add_circle;
      case 'toggle_on':
        return Icons.toggle_on;
      case 'check_box':
        return Icons.check_box;
      case 'radio_button_checked':
        return Icons.radio_button_checked;
      case 'tune':
        return Icons.tune;
      case 'arrow_drop_down':
        return Icons.arrow_drop_down;
      case 'grid_on':
        return Icons.grid_on;
      case 'swap_vert':
        return Icons.swap_vert;
      case 'view_carousel':
        return Icons.view_carousel;
      case 'view_headline':
        return Icons.view_headline;
      case 'tab':
        return Icons.tab;
      case 'menu':
        return Icons.menu;
      case 'dashboard':
        return Icons.dashboard;
      case 'security':
        return Icons.security;
      case 'aspect_ratio':
        return Icons.aspect_ratio;
      case 'hourglass_empty':
        return Icons.hourglass_empty;
      case 'stream':
        return Icons.stream;
      default:
        return Icons.widgets;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}