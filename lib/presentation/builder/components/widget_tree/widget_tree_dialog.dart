
// lib/presentation/builder/components/widget_tree/widget_tree_dialog.dart
import 'package:flutter/material.dart';
import '../../../../data/models/app_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../utils/widget_helpers.dart';

class WidgetTreeDialog extends StatelessWidget {
  final List<AppWidget> widgets;

  const WidgetTreeDialog({
    super.key,
    required this.widgets,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 400,
        height: 600,
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: _buildTreeView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
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
    );
  }

  Widget _buildTreeView() {
    if (widgets.isEmpty) {
      return const Center(
        child: Text('No widgets added yet'),
      );
    }

    // Build tree structure
    final Map<int?, List<AppWidget>> widgetsByParent = {};
    for (var widget in widgets) {
      final parentId = widget.parentWidget;
      widgetsByParent[parentId] ??= [];
      widgetsByParent[parentId]!.add(widget);
    }

    final rootWidgets = widgetsByParent[null] ?? [];

    return ListView.builder(
      itemCount: rootWidgets.length,
      itemBuilder: (context, index) {
        return _buildTreeNode(rootWidgets[index], widgetsByParent, 0);
      },
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.only(left: depth * 20.0),
          height: 30,
          child: Row(
            children: [
              if (children.isNotEmpty)
                Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[600])
              else
                const SizedBox(width: 20),
              Icon(
                WidgetHelpers.getWidgetIcon(widget.widgetType),
                size: 16,
                color: WidgetHelpers.getWidgetColor(widget.widgetType),
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
}