// lib/data/models/data_source_field.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_source_field.g.dart';

@JsonSerializable()
class DataSourceField extends Equatable {
  final int id;
  @JsonKey(name: 'data_source')
  final int dataSource;
  @JsonKey(name: 'field_name')
  final String fieldName;
  @JsonKey(name: 'field_type')
  final String fieldType;
  @JsonKey(name: 'display_name')
  final String displayName;
  @JsonKey(name: 'is_required')
  final bool isRequired;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const DataSourceField({
    required this.id,
    required this.dataSource,
    required this.fieldName,
    required this.fieldType,
    required this.displayName,
    required this.isRequired,
    required this.createdAt,
  });

  factory DataSourceField.fromJson(Map<String, dynamic> json) {
    try {
      // Parse DateTime safely
      DateTime parseDate(dynamic date) {
        if (date == null) return DateTime.now();
        if (date is String) return DateTime.parse(date);
        return DateTime.now();
      }

      return DataSourceField(
        id: json['id'] as int,
        dataSource: json['data_source'] as int,
        fieldName: json['field_name']?.toString() ?? '',
        fieldType: json['field_type']?.toString() ?? 'string',
        displayName: json['display_name']?.toString() ?? '',
        isRequired: json['is_required'] == true,
        createdAt: parseDate(json['created_at']),
      );
    } catch (e) {
      print('Error parsing DataSourceField: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$DataSourceFieldToJson(this);

  @override
  List<Object?> get props => [
    id, dataSource, fieldName, fieldType, displayName, isRequired, createdAt
  ];
}