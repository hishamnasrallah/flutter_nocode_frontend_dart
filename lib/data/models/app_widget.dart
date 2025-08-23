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

  factory AppWidget.fromJson(Map<String, dynamic> json) => _$AppWidgetFromJson(json);
  Map<String, dynamic> toJson() => _$AppWidgetToJson(this);

  @override
  List<Object?> get props => [
    id, screen, widgetType, parentWidget, order, widgetId,
    properties, childWidgets, canHaveChildren, createdAt, updatedAt
  ];
}