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

  factory WidgetProperty.fromJson(Map<String, dynamic> json) {
    // Robust helper to parse strings (handles null, empty, and any type)
    String? parseString(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return value.isEmpty ? null : value;
      }
      return value.toString();
    }

    // Robust helper to parse integers (handles String, double, int, null)
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        if (value.isEmpty) return null;
        // Try to parse as double first (in case it's "24.0"), then convert to int
        final doubleValue = double.tryParse(value);
        if (doubleValue != null) return doubleValue.toInt();
        // Try direct int parse
        return int.tryParse(value);
      }
      if (value is bool) return value ? 1 : 0;
      return null;
    }

    // Robust helper to parse doubles (handles String, int, double, null)
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        if (value.isEmpty) return null;
        return double.tryParse(value);
      }
      if (value is bool) return value ? 1.0 : 0.0;
      return null;
    }

    // Robust helper to parse booleans (handles String, int, bool, null)
    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true' || lower == '1' || lower == 'yes' || lower == 'on') return true;
        if (lower == 'false' || lower == '0' || lower == 'no' || lower == 'off' || lower.isEmpty) return false;
        return null;
      }
      if (value is int) return value != 0;
      if (value is double) return value != 0.0;
      return false;
    }

    // Robust helper to parse DateTime (handles various formats)
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          // If parsing fails, return current time
          return DateTime.now();
        }
      }
      if (value is int) {
        // Assume it's milliseconds since epoch
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.now();
    }

    // Robust helper to parse reference IDs (handles String, int, double, null)
    int? parseReference(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        if (value.isEmpty) return null;
        // Try to parse as double first, then convert to int
        final doubleValue = double.tryParse(value);
        if (doubleValue != null) return doubleValue.toInt();
        return int.tryParse(value);
      }
      return null;
    }

    try {
      return WidgetProperty(
        id: parseInt(json['id']) ?? 0,  // Ensure id is never null
        widget: parseInt(json['widget']) ?? 0,  // Ensure widget is never null
        propertyName: parseString(json['property_name']) ?? 'unknown',  // Ensure propertyName is never null
        propertyType: parseString(json['property_type']) ?? 'string',  // Ensure propertyType is never null
        stringValue: parseString(json['string_value']),
        integerValue: parseInt(json['integer_value']),
        decimalValue: parseDouble(json['decimal_value']),
        booleanValue: parseBool(json['boolean_value']),
        colorValue: parseString(json['color_value']),
        alignmentValue: parseString(json['alignment_value']),
        urlValue: parseString(json['url_value']),
        jsonValue: parseString(json['json_value']),
        actionReference: parseReference(json['action_reference']),
        dataSourceFieldReference: parseReference(json['data_source_field_reference']),
        screenReference: parseReference(json['screen_reference']),
        createdAt: parseDateTime(json['created_at']),
        value: json['value'],  // Keep as dynamic
      );
    } catch (e) {
      // If all else fails, return a minimal valid object
      return WidgetProperty(
        id: 0,
        widget: 0,
        propertyName: 'error',
        propertyType: 'string',
        createdAt: DateTime.now(),
        value: null,
      );
    }
  }

  Map<String, dynamic> toJson() => _$WidgetPropertyToJson(this);

  @override
  List<Object?> get props => [
    id, widget, propertyName, propertyType, stringValue, integerValue,
    decimalValue, booleanValue, colorValue, alignmentValue, urlValue,
    jsonValue, actionReference, dataSourceFieldReference, screenReference,
    createdAt, value
  ];

  // Get the effective value for this property
  dynamic get effectiveValue {
    return value ?? getValue();
  }

  // Get the typed value based on property type
  dynamic getValue() {
    switch (propertyType) {
      case 'string':
        return stringValue;
      case 'integer':
        return integerValue;
      case 'decimal':
        return decimalValue;
      case 'boolean':
        return booleanValue;
      case 'color':
        return colorValue;
      case 'alignment':
        return alignmentValue;
      case 'url':
        return urlValue;
      case 'json':
        return jsonValue;
      case 'action_reference':
        return actionReference;
      case 'data_source_field_reference':
        return dataSourceFieldReference;
      case 'screen_reference':
        return screenReference;
      default:
        return value;
    }
  }

  // Helper method to get value as string (useful for display)
  String getDisplayValue() {
    final val = effectiveValue;
    if (val == null) return '';
    if (val is String) return val;
    if (val is bool) return val ? 'Yes' : 'No';
    if (val is DateTime) return val.toIso8601String();
    return val.toString();
  }

  // Copy with method for updating properties
  WidgetProperty copyWith({
    int? id,
    int? widget,
    String? propertyName,
    String? propertyType,
    String? stringValue,
    int? integerValue,
    double? decimalValue,
    bool? booleanValue,
    String? colorValue,
    String? alignmentValue,
    String? urlValue,
    String? jsonValue,
    int? actionReference,
    int? dataSourceFieldReference,
    int? screenReference,
    DateTime? createdAt,
    dynamic value,
  }) {
    return WidgetProperty(
      id: id ?? this.id,
      widget: widget ?? this.widget,
      propertyName: propertyName ?? this.propertyName,
      propertyType: propertyType ?? this.propertyType,
      stringValue: stringValue ?? this.stringValue,
      integerValue: integerValue ?? this.integerValue,
      decimalValue: decimalValue ?? this.decimalValue,
      booleanValue: booleanValue ?? this.booleanValue,
      colorValue: colorValue ?? this.colorValue,
      alignmentValue: alignmentValue ?? this.alignmentValue,
      urlValue: urlValue ?? this.urlValue,
      jsonValue: jsonValue ?? this.jsonValue,
      actionReference: actionReference ?? this.actionReference,
      dataSourceFieldReference: dataSourceFieldReference ?? this.dataSourceFieldReference,
      screenReference: screenReference ?? this.screenReference,
      createdAt: createdAt ?? this.createdAt,
      value: value ?? this.value,
    );
  }
}