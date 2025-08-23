// lib/data/models/app_widget.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'widget_property.dart';

part 'app_widget.g.dart';

@JsonSerializable()
class AppWidget extends Equatable {
  final int id;
  final int screen;
  final String widgetType;
  final int? parentWidget;
  final int order;
  final String? widgetId;
  final List<WidgetProperty>? properties;
  final List<AppWidget>? childWidgets;
  final bool? canHaveChildren;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppWidget({
    required this.id,
    required this.screen,
    required this.widgetType,
    this.parentWidget,
    required this.order,
    this.widgetId,
    this.properties,
    this.childWidgets,
    this.canHaveChildren,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppWidget.fromJson(Map<String, dynamic> json) {
  // Parse DateTime safely
  DateTime parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  // Parse child widgets safely
  List<AppWidget>? parseChildWidgets(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((w) => AppWidget.fromJson(w)).toList();
    }
    return null;
  }

  // Parse properties safely
  List<WidgetProperty>? parseProperties(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((p) => WidgetProperty.fromJson(p)).toList();
    }
    return null;
  }

  return AppWidget(
    id: json['id'] as int,
    screen: json['screen'] as int,
    widgetType: json['widget_type']?.toString() ?? 'Container',
    parentWidget: json['parent_widget'] as int?,
    order: json['order'] as int? ?? 0,
    widgetId: json['widget_id']?.toString(),
    properties: parseProperties(json['properties']),
    childWidgets: parseChildWidgets(json['child_widgets']),
    canHaveChildren: json['can_have_children'] as bool?,
    createdAt: parseDate(json['created_at']),
    updatedAt: parseDate(json['updated_at']),
  );
}

  @override
  List<Object?> get props => [
    id, screen, widgetType, parentWidget, order, widgetId,
    properties, childWidgets, canHaveChildren, createdAt, updatedAt
  ];
}