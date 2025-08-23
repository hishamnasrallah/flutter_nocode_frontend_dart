// lib/data/models/widget_property.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget_property.g.dart';

@JsonSerializable()
class WidgetProperty extends Equatable {
  final int id;
  final int widget;
  final String propertyName;
  final String propertyType;
  final String? stringValue;
  final int? integerValue;
  final double? decimalValue;
  final bool? booleanValue;
  final String? colorValue;
  final String? alignmentValue;
  final String? urlValue;
  final String? jsonValue;
  final int? actionReference;
  final int? dataSourceFieldReference;
  final int? screenReference;
  final DateTime createdAt;
  final dynamic value;

  const WidgetProperty({
    required this.id,
    required this.widget,
    required this.propertyName,
    required this.propertyType,
    this.stringValue,
    this.integerValue,
    this.decimalValue,
    this.booleanValue,
    this.colorValue,
    this.alignmentValue,
    this.urlValue,
    this.jsonValue,
    this.actionReference,
    this.dataSourceFieldReference,
    this.screenReference,
    required this.createdAt,
    this.value,
  });

  factory WidgetProperty.fromJson(Map<String, dynamic> json) => _$WidgetPropertyFromJson(json);
  Map<String, dynamic> toJson() => _$WidgetPropertyToJson(this);

  @override
  List<Object?> get props => [
    id, widget, propertyName, propertyType, stringValue, integerValue,
    decimalValue, booleanValue, colorValue, alignmentValue, urlValue,
    jsonValue, actionReference, dataSourceFieldReference, screenReference,
    createdAt, value
  ];
}
