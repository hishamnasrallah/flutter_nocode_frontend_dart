// lib/presentation/builder/components/canvas/live_preview_renderer.dart
import 'package:flutter/material.dart';
import '../../../../data/models/screen.dart';
import '../../../../data/models/app_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../utils/widget_helpers.dart';

class LivePreviewRenderer extends StatelessWidget {
  final Screen screen;
  final List<AppWidget> widgets;
  final AppWidget? selectedWidget;
  final Function(AppWidget?) onWidgetSelected;
  final Function(Map<String, dynamic>) onWidgetDropped;
  final Function(AppWidget, AppWidget?) onWidgetMoved;
  final bool isInteractive;

  const LivePreviewRenderer({
    super.key,
    required this.screen,
    required this.widgets,
    required this.selectedWidget,
    required this.onWidgetSelected,
    required this.onWidgetDropped,
    required this.onWidgetMoved,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAccept: onWidgetDropped,
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: screen.backgroundColor != null
                ? Color(int.parse(screen.backgroundColor!.replaceAll('#', '0xFF')))
                : Colors.white,
            border: isHighlighted
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Column(
            children: [
              if (screen.showAppBar) _buildAppBar(),
              Expanded(
                child: widgets.isEmpty
                    ? _buildEmptyState(isHighlighted)
                    : _buildWidgetTree(),
              ),
            ],
          ),
        );
      },
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

  Widget _buildEmptyState(bool isHighlighted) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_box_outlined,
              size: 64,
              color: isHighlighted ? AppColors.primary : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Drop widgets here',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isHighlighted ? AppColors.primary : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Drag widgets from the panel to start building',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

    if (rootWidgets.isEmpty) {
      return _buildEmptyState(false);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rootWidgets.map((widget) {
          return _buildWidgetNode(widget, widgetsByParent);
        }).toList(),
      ),
    );
  }

  Widget _buildWidgetNode(
    AppWidget widgetModel,
    Map<int?, List<AppWidget>> widgetsByParent,
  ) {
    final isSelected = selectedWidget?.id == widgetModel.id;
    final children = widgetsByParent[widgetModel.id] ?? [];

    Widget widgetContent = _buildWidgetContent(widgetModel, children, widgetsByParent);

    // Wrap with selection and interaction handling
    if (isInteractive) {
      widgetContent = InkWell(
        onTap: () => onWidgetSelected(widgetModel),
        child: Container(
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
            color: isSelected
                ? AppColors.primary.withOpacity(0.05)
                : null,
          ),
          child: widgetContent,
        ),
      );
    }

    return widgetContent;
  }

  Widget _buildWidgetContent(
    AppWidget widgetModel,
    List<AppWidget> children,
    Map<int?, List<AppWidget>> widgetsByParent,
  ) {
    Widget content;

    switch (widgetModel.widgetType) {
      case 'Container':
        content = Container(
          width: _getPropertyValue(widgetModel, 'width')?.toDouble(),
          height: _getPropertyValue(widgetModel, 'height')?.toDouble(),
          padding: EdgeInsets.all(_getPropertyValue(widgetModel, 'padding')?.toDouble() ?? 0),
          margin: EdgeInsets.all(_getPropertyValue(widgetModel, 'margin')?.toDouble() ?? 0),
          decoration: BoxDecoration(
            color: _getColorProperty(widgetModel, 'backgroundColor'),
            borderRadius: BorderRadius.circular(
              _getPropertyValue(widgetModel, 'borderRadius')?.toDouble() ?? 0,
            ),
          ),
          child: children.isNotEmpty
              ? _buildChildren(children, widgetsByParent)
              : null,
        );
        break;

      case 'Column':
        content = Column(
          mainAxisAlignment: _getMainAxisAlignment(widgetModel),
          crossAxisAlignment: _getCrossAxisAlignment(widgetModel),
          mainAxisSize: _getMainAxisSize(widgetModel),
          children: children.isEmpty
              ? [_buildPlaceholder('Add widgets to Column')]
              : children.map((child) => _buildWidgetNode(child, widgetsByParent)).toList(),
        );
        break;

      case 'Row':
        content = Row(
          mainAxisAlignment: _getMainAxisAlignment(widgetModel),
          crossAxisAlignment: _getCrossAxisAlignment(widgetModel),
          mainAxisSize: _getMainAxisSize(widgetModel),
          children: children.isEmpty
              ? [_buildPlaceholder('Add widgets to Row')]
              : children.map((child) => _buildWidgetNode(child, widgetsByParent)).toList(),
        );
        break;

      case 'Text':
        content = Text(
          _getPropertyValue(widgetModel, 'text')?.toString() ?? 'Sample Text',
          style: TextStyle(
            fontSize: _getPropertyValue(widgetModel, 'fontSize')?.toDouble() ?? 14,
            fontWeight: _getFontWeight(widgetModel),
            color: _getColorProperty(widgetModel, 'color'),
          ),
          textAlign: _getTextAlign(widgetModel),
        );
        break;

      case 'ElevatedButton':
        content = ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: _getColorProperty(widgetModel, 'backgroundColor'),
            foregroundColor: _getColorProperty(widgetModel, 'textColor'),
          ),
          child: Text(
            _getPropertyValue(widgetModel, 'text')?.toString() ?? 'Button',
          ),
        );
        break;

      case 'TextField':
        content = TextField(
          decoration: InputDecoration(
            labelText: _getPropertyValue(widgetModel, 'labelText')?.toString(),
            hintText: _getPropertyValue(widgetModel, 'hintText')?.toString(),
            helperText: _getPropertyValue(widgetModel, 'helperText')?.toString(),
            border: const OutlineInputBorder(),
          ),
          obscureText: _getPropertyValue(widgetModel, 'obscureText') == true,
          maxLines: _getPropertyValue(widgetModel, 'maxLines')?.toInt() ?? 1,
        );
        break;

      case 'Image':
        final imageUrl = _getPropertyValue(widgetModel, 'imageUrl')?.toString();
        content = imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: _getPropertyValue(widgetModel, 'width')?.toDouble(),
                height: _getPropertyValue(widgetModel, 'height')?.toDouble(),
                fit: _getBoxFit(widgetModel),
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder();
        break;

      case 'Icon':
        content = Icon(
          _getIconData(widgetModel),
          size: _getPropertyValue(widgetModel, 'size')?.toDouble() ?? 24,
          color: _getColorProperty(widgetModel, 'color'),
        );
        break;

      case 'Card':
        content = Card(
          elevation: _getPropertyValue(widgetModel, 'elevation')?.toDouble() ?? 2,
          color: _getColorProperty(widgetModel, 'color'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: children.isNotEmpty
                ? _buildChildren(children, widgetsByParent)
                : _buildPlaceholder('Card Content'),
          ),
        );
        break;

      case 'ListView':
        content = SizedBox(
          height: 200, // Default height for preview
          child: ListView(
            scrollDirection: _getScrollDirection(widgetModel),
            shrinkWrap: true,
            children: children.isEmpty
                ? [_buildPlaceholder('List Item 1'), _buildPlaceholder('List Item 2')]
                : children.map((child) => _buildWidgetNode(child, widgetsByParent)).toList(),
          ),
        );
        break;

      case 'Stack':
        content = Stack(
          alignment: _getStackAlignment(widgetModel),
          children: children.isEmpty
              ? [_buildPlaceholder('Stack Layer')]
              : children.map((child) => _buildWidgetNode(child, widgetsByParent)).toList(),
        );
        break;

      case 'Padding':
        content = Padding(
          padding: EdgeInsets.all(_getPropertyValue(widgetModel, 'padding')?.toDouble() ?? 8),
          child: children.isNotEmpty
              ? _buildChildren(children, widgetsByParent)
              : _buildPlaceholder('Padded Content'),
        );
        break;

      case 'Center':
        content = Center(
          child: children.isNotEmpty
              ? _buildChildren(children, widgetsByParent)
              : _buildPlaceholder('Centered Content'),
        );
        break;

      case 'SizedBox':
        content = SizedBox(
          width: _getPropertyValue(widgetModel, 'width')?.toDouble(),
          height: _getPropertyValue(widgetModel, 'height')?.toDouble(),
          child: children.isNotEmpty
              ? _buildChildren(children, widgetsByParent)
              : null,
        );
        break;

      default:
        content = _buildUnknownWidget(widgetModel);
    }

    return content;
  }

  Widget _buildChildren(
    List<AppWidget> children,
    Map<int?, List<AppWidget>> widgetsByParent,
  ) {
    if (children.length == 1) {
      return _buildWidgetNode(children.first, widgetsByParent);
    }
    return Column(
      children: children.map((child) => _buildWidgetNode(child, widgetsByParent)).toList(),
    );
  }

  Widget _buildPlaceholder(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildUnknownWidget(AppWidget widgetModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[200]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.widgets,
            size: 16,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 8),
          Text(
            widgetModel.widgetType,
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods to get property values
  dynamic _getPropertyValue(AppWidget widget, String propertyName) {
    if (widget.properties == null) return null;
    try {
      final property = widget.properties!.firstWhere(
        (p) => p.propertyName == propertyName,
      );
      return property.effectiveValue;
    } catch (e) {
      return null;
    }
  }

  Color? _getColorProperty(AppWidget widget, String propertyName) {
    final value = _getPropertyValue(widget, propertyName);
    if (value == null) return null;
    if (value is Color) return value;
    if (value is String) {
      try {
        return Color(int.parse(value.replaceAll('#', '0xFF')));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  MainAxisAlignment _getMainAxisAlignment(AppWidget widget) {
    final value = _getPropertyValue(widget, 'mainAxisAlignment')?.toString();
    switch (value) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _getCrossAxisAlignment(AppWidget widget) {
    final value = _getPropertyValue(widget, 'crossAxisAlignment')?.toString();
    switch (value) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.center;
    }
  }

  MainAxisSize _getMainAxisSize(AppWidget widget) {
    final value = _getPropertyValue(widget, 'mainAxisSize')?.toString();
    return value == 'min' ? MainAxisSize.min : MainAxisSize.max;
  }

  TextAlign _getTextAlign(AppWidget widget) {
    final value = _getPropertyValue(widget, 'textAlign')?.toString();
    switch (value) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }

  FontWeight _getFontWeight(AppWidget widget) {
    final value = _getPropertyValue(widget, 'fontWeight')?.toString();
    switch (value) {
      case 'bold':
        return FontWeight.bold;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  BoxFit _getBoxFit(AppWidget widget) {
    final value = _getPropertyValue(widget, 'fit')?.toString();
    switch (value) {
      case 'cover':
        return BoxFit.cover;
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'none':
        return BoxFit.none;
      case 'scaleDown':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }

  Axis _getScrollDirection(AppWidget widget) {
    final value = _getPropertyValue(widget, 'scrollDirection')?.toString();
    return value == 'horizontal' ? Axis.horizontal : Axis.vertical;
  }

  AlignmentGeometry _getStackAlignment(AppWidget widget) {
    final value = _getPropertyValue(widget, 'alignment')?.toString();
    switch (value) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        return Alignment.topLeft;
    }
  }

  IconData _getIconData(AppWidget widget) {
    final iconName = _getPropertyValue(widget, 'icon')?.toString();
    // Map icon names to IconData
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'person':
        return Icons.person;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.help_outline;
    }
  }
}