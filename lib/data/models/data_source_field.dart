
// lib/data/models/data_source_field.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_source_field.g.dart';

@JsonSerializable()
class DataSourceField extends Equatable {
  final int id;
  final int dataSource;
  final String fieldName;
  final String fieldType;
  final String displayName;
  final bool isRequired;
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

  factory DataSourceField.fromJson(Map<String, dynamic> json) => _$DataSourceFieldFromJson(json);
  Map<String, dynamic> toJson() => _$DataSourceFieldToJson(this);

  @override
  List<Object?> get props => [
    id, dataSource, fieldName, fieldType, displayName, isRequired, createdAt
  ];
}