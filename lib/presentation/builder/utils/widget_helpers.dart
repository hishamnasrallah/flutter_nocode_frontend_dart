
// lib/presentation/builder/utils/widget_helpers.dart
import 'package:flutter/material.dart';
import '../../../data/models/app_widget.dart';
import '../../../core/constants/app_colors.dart';

class WidgetHelpers {
  static Color getWidgetColor(String widgetType) {
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

  static IconData getWidgetIcon(String widgetType) {
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

  static Widget buildWidgetPreview(AppWidget widgetModel) {
    Widget preview;

    switch (widgetModel.widgetType) {
      case 'Text':
        preview = Text(
          _getPropertyValue(widgetModel, 'text') ?? 'Sample Text',
          style: TextStyle(color: Colors.grey[700]),
        );
        break;
      case 'Button':
      case 'ElevatedButton':
        preview = Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _getPropertyValue(widgetModel, 'text') ?? 'Button',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
        break;
      case 'TextField':
        preview = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _getPropertyValue(widgetModel, 'hintText') ?? 'Enter text...',
            style: TextStyle(color: Colors.grey[500]),
          ),
        );
        break;
      case 'Image':
        preview = Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Icon(Icons.image, color: Colors.grey),
          ),
        );
        break;
      case 'Container':
        preview = Container(
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
        break;
      default:
        preview = Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            widgetModel.widgetType,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        );
    }

    return SizedBox(
      width: double.infinity,
      child: preview,
    );
  }

  static String? _getPropertyValue(AppWidget widgetModel, String propertyName) {
    if (widgetModel.properties == null) return null;

    try {
      final property = widgetModel.properties!.firstWhere(
        (p) => p.propertyName == propertyName,
      );
      return property.getDisplayValue();
    } catch (e) {
      return null;
    }
  }
}
