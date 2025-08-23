// lib/data/models/data_source.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'data_source_field.dart';

part 'data_source.g.dart';

@JsonSerializable()
class DataSource extends Equatable {
  final int id;
  final int application;
  final String name;
  final String dataSourceType;
  final String? baseUrl;
  final String? endpoint;
  final String method;
  final String? headers;
  final bool useDynamicBaseUrl;
  final List<DataSourceField>? fields;
  final int? fieldsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DataSource({
    required this.id,
    required this.application,
    required this.name,
    required this.dataSourceType,
    this.baseUrl,
    this.endpoint,
    required this.method,
    this.headers,
    required this.useDynamicBaseUrl,
    this.fields,
    this.fieldsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DataSource.fromJson(Map<String, dynamic> json) => _$DataSourceFromJson(json);
  Map<String, dynamic> toJson() => _$DataSourceToJson(this);

  @override
  List<Object?> get props => [
    id, application, name, dataSourceType, baseUrl, endpoint,
    method, headers, useDynamicBaseUrl, fields, fieldsCount,
    createdAt, updatedAt
  ];
}
