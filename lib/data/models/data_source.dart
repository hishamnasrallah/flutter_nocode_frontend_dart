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
  @JsonKey(name: 'data_source_type')
  final String dataSourceType;
  @JsonKey(name: 'base_url')
  final String? baseUrl;
  final String? endpoint;
  final String method;
  final String? headers;
  @JsonKey(name: 'use_dynamic_base_url')
  final bool useDynamicBaseUrl;
  final List<DataSourceField>? fields;
  @JsonKey(name: 'fields_count')
  final int? fieldsCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
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

  factory DataSource.fromJson(Map<String, dynamic> json) {
    try {
      // Parse DateTime safely
      DateTime parseDate(dynamic date) {
        if (date == null) return DateTime.now();
        if (date is String) return DateTime.parse(date);
        return DateTime.now();
      }

      // Parse fields list safely
      List<DataSourceField>? parseFields(dynamic data) {
        if (data == null) return null;
        if (data is List) {
          return data.map((f) => DataSourceField.fromJson(f)).toList();
        }
        return null;
      }

      return DataSource(
        id: json['id'] as int,
        application: json['application'] as int,
        name: json['name']?.toString() ?? 'Unnamed',
        dataSourceType: json['data_source_type']?.toString() ?? 'REST_API',
        baseUrl: json['base_url']?.toString(),
        endpoint: json['endpoint']?.toString(),
        method: json['method']?.toString() ?? 'GET',
        headers: json['headers']?.toString(),
        useDynamicBaseUrl: json['use_dynamic_base_url'] == true,
        fields: parseFields(json['fields']),
        fieldsCount: json['fields_count'] as int?,
        createdAt: parseDate(json['created_at']),
        updatedAt: parseDate(json['updated_at']),
      );
    } catch (e) {
      print('Error parsing DataSource: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$DataSourceToJson(this);

  @override
  List<Object?> get props => [
    id, application, name, dataSourceType, baseUrl, endpoint,
    method, headers, useDynamicBaseUrl, fields, fieldsCount,
    createdAt, updatedAt
  ];
}