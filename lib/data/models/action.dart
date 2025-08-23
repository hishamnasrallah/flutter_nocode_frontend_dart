// lib/data/models/action.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'action.g.dart';

@JsonSerializable()
class AppAction extends Equatable {
  final int id;
  final int application;
  final String name;
  final String actionType;
  final int? targetScreen;
  final String? targetScreenName;
  final int? apiDataSource;
  final String? apiDataSourceName;
  final String? parameters;
  final String? dialogTitle;
  final String? dialogMessage;
  final String? url;
  final DateTime createdAt;
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

  factory AppAction.fromJson(Map<String, dynamic> json) => _$AppActionFromJson(json);
  Map<String, dynamic> toJson() => _$AppActionToJson(this);

  @override
  List<Object?> get props => [
    id, application, name, actionType, targetScreen, targetScreenName,
    apiDataSource, apiDataSourceName, parameters, dialogTitle,
    dialogMessage, url, createdAt, updatedAt
  ];
}