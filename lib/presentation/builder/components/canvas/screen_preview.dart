// lib/presentation/builder/components/canvas/screen_preview.dart
import 'package:flutter/material.dart';
import '../../../../data/models/screen.dart';
import '../../../../data/models/app_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../widget_tree/widget_node.dart';

class ScreenPreview extends StatelessWidget {
  final Screen screen;
  final List<AppWidget> widgets;
  final AppWidget? selectedWidget;
  final bool showOutlines;
  final Function(AppWidget?) onWidgetSelected;
  final Function(AppWidget) onWidgetDeleted;
  final Function(AppWidget, int) onWidgetReordered;
  final Function(AppWidget) onWidgetDuplicated;
  final Function(Map<String, dynamic>) onWidgetAdded;

  const ScreenPreview({
    super.key,
    required this.screen,
    required this.widgets,
    required this.selectedWidget,
    required this.showOutlines,
    required this.onWidgetSelected,
    required this.onWidgetDeleted,
    required this.onWidgetReordered,
    required this.onWidgetDuplicated,
    required this.onWidgetAdded,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate available height
    final appBarHeight = screen.showAppBar ? 56.0 : 0.0;
    final contentHeight = 667.0 - appBarHeight; // Total device height minus app bar

    return Column(
      children: [
        // App bar
        if (screen.showAppBar) _buildAppBar(),

        // Screen content with fixed height
        Container(
          height: contentHeight,
          color: screen.backgroundColor != null
              ? Color(int.parse(screen.backgroundColor!.replaceAll('#', '0xFF')))
              : Colors.white,
          child: widgets.isEmpty
              ? _buildEmptyCanvas()
              : _buildWidgetTree(),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
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
    );
  }

  Widget _buildEmptyCanvas() {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAccept: onWidgetAdded,
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isHighlighted ? AppColors.primary : Colors.grey[300]!,
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
                    color: isHighlighted ? AppColors.primary : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Drop widgets here',
                    style: TextStyle(
                      color: isHighlighted ? AppColors.primary : Colors.grey[600],
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
          ),
        );
      },
    );
  }

  Widget _buildWidgetTree() {
    // Group widgets by parent
    final Map<int?, List<AppWidget>> widgetsByParent = {};
    for (var widget in widgets) {
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: rootWidgets.map((widget) {
        return WidgetNode(
          widgetModel: widget,
          widgetsByParent: widgetsByParent,
          selectedWidget: selectedWidget,
          showOutlines: showOutlines,
          depth: 0,
          onWidgetSelected: onWidgetSelected,
          onWidgetDeleted: onWidgetDeleted,
          onWidgetReordered: onWidgetReordered,
          onWidgetDuplicated: onWidgetDuplicated,
        );
      }).toList(),
    );
  }
}