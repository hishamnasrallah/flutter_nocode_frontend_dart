// lib/presentation/builder/components/widget_tree/widget_node.dart
import 'package:flutter/material.dart';
import '../../../../data/models/app_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../utils/widget_helpers.dart';

class WidgetNode extends StatelessWidget {
  final AppWidget widgetModel;
  final Map<int?, List<AppWidget>> widgetsByParent;
  final AppWidget? selectedWidget;
  final bool showOutlines;
  final int depth;
  final Function(AppWidget?) onWidgetSelected;
  final Function(AppWidget) onWidgetDeleted;
  final Function(AppWidget, int) onWidgetReordered;
  final Function(AppWidget) onWidgetDuplicated;

  const WidgetNode({
    super.key,
    required this.widgetModel,
    required this.widgetsByParent,
    required this.selectedWidget,
    required this.showOutlines,
    required this.depth,
    required this.onWidgetSelected,
    required this.onWidgetDeleted,
    required this.onWidgetReordered,
    required this.onWidgetDuplicated,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedWidget?.id == widgetModel.id;
    final children = widgetsByParent[widgetModel.id] ?? [];
    final hasChildren = children.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(left: depth * 20.0, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildWidgetCard(context, isSelected, hasChildren),
          if (hasChildren) _buildChildren(children),
        ],
      ),
    );
  }

  Widget _buildWidgetCard(BuildContext context, bool isSelected, bool hasChildren) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('Widget tapped: ${widgetModel.widgetType} (ID: ${widgetModel.id})');
          onWidgetSelected(widgetModel);
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : showOutlines
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
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWidgetHeader(context, hasChildren, isSelected),
              if (!hasChildren) _buildWidgetPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetHeader(BuildContext context, bool hasChildren, bool isSelected) {
    final color = WidgetHelpers.getWidgetColor(widgetModel.widgetType);
    final icon = WidgetHelpers.getWidgetIcon(widgetModel.widgetType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widgetModel.widgetType,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widgetModel.widgetId != null)
                  Text(
                    '#${widgetModel.widgetId}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (hasChildren)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(widgetsByParent[widgetModel.id] ?? []).length}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          SizedBox(
            width: 24,
            height: 24,
            child: _buildActionMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      iconSize: 16,
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 24,
        minHeight: 24,
      ),
      onSelected: (value) {
        switch (value) {
          case 'delete':
            onWidgetDeleted(widgetModel);
            break;
          case 'duplicate':
            onWidgetDuplicated(widgetModel);
            break;
          case 'moveUp':
            if (widgetModel.order > 0) {
              onWidgetReordered(widgetModel, widgetModel.order - 1);
            }
            break;
          case 'moveDown':
            onWidgetReordered(widgetModel, widgetModel.order + 1);
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
    );
  }

  Widget _buildWidgetPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minHeight: 40),
      child: WidgetHelpers.buildWidgetPreview(widgetModel),
    );
  }

  Widget _buildChildren(List<AppWidget> children) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: children.map((child) {
          return WidgetNode(
            widgetModel: child,
            widgetsByParent: widgetsByParent,
            selectedWidget: selectedWidget,
            showOutlines: showOutlines,
            depth: depth + 1,
            onWidgetSelected: onWidgetSelected,
            onWidgetDeleted: onWidgetDeleted,
            onWidgetReordered: onWidgetReordered,
            onWidgetDuplicated: onWidgetDuplicated,
          );
        }).toList(),
      ),
    );
  }
}