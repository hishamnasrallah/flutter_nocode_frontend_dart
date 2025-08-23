// lib/data/models/action.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'action.g.dart';

@JsonSerializable()
class AppAction extends Equatable {
  final int id;
  final int application;
  final String name;
  @JsonKey(name: 'action_type')
  final String actionType;
  @JsonKey(name: 'target_screen')
  final int? targetScreen;
  @JsonKey(name: 'target_screen_name')
  final String? targetScreenName;
  @JsonKey(name: 'api_data_source')
  final int? apiDataSource;
  @JsonKey(name: 'api_data_source_name')
  final String? apiDataSourceName;
  final String? parameters;
  @JsonKey(name: 'dialog_title')
  final String? dialogTitle;
  @JsonKey(name: 'dialog_message')
  final String? dialogMessage;
  final String? url;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const AppAction({
    required this.id,
    required this.application,
    required this.name,
    required this.actionType,
    this.targetScreen,
    this.targetScreenName,
    this.apiDataSource,
    this.apiDataSourceName,
    this.parameters,
    this.dialogTitle,
    this.dialogMessage,
    this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppAction.fromJson(Map<String, dynamic> json) {
    try {
      // Parse DateTime safely
      DateTime parseDate(dynamic date) {
        if (date == null) return DateTime.now();
        if (date is String) return DateTime.parse(date);
        return DateTime.now();
      }

      return AppAction(
        id: json['id'] as int,
        application: json['application'] as int,
        name: json['name']?.toString() ?? 'Unnamed Action',
        actionType: json['action_type']?.toString() ?? 'navigate',
        targetScreen: json['target_screen'] as int?,
        targetScreenName: json['target_screen_name']?.toString(),
        apiDataSource: json['api_data_source'] as int?,
        apiDataSourceName: json['api_data_source_name']?.toString(),
        parameters: json['parameters']?.toString(),
        dialogTitle: json['dialog_title']?.toString(),
        dialogMessage: json['dialog_message']?.toString(),
        url: json['url']?.toString(),
        createdAt: parseDate(json['created_at']),
        updatedAt: parseDate(json['updated_at']),
      );
    } catch (e) {
      print('Error parsing AppAction: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$AppActionToJson(this);

  @override
  List<Object?> get props => [
    id, application, name, actionType, targetScreen, targetScreenName,
    apiDataSource, apiDataSourceName, parameters, dialogTitle,
    dialogMessage, url, createdAt, updatedAt
  ];
}