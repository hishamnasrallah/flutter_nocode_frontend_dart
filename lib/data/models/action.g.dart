// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppAction _$AppActionFromJson(Map<String, dynamic> json) => AppAction(
      id: (json['id'] as num).toInt(),
      application: (json['application'] as num).toInt(),
      name: json['name'] as String,
      actionType: json['actionType'] as String,
      targetScreen: (json['targetScreen'] as num?)?.toInt(),
      targetScreenName: json['targetScreenName'] as String?,
      apiDataSource: (json['apiDataSource'] as num?)?.toInt(),
      apiDataSourceName: json['apiDataSourceName'] as String?,
      parameters: json['parameters'] as String?,
      dialogTitle: json['dialogTitle'] as String?,
      dialogMessage: json['dialogMessage'] as String?,
      url: json['url'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AppActionToJson(AppAction instance) => <String, dynamic>{
      'id': instance.id,
      'application': instance.application,
      'name': instance.name,
      'actionType': instance.actionType,
      'targetScreen': instance.targetScreen,
      'targetScreenName': instance.targetScreenName,
      'apiDataSource': instance.apiDataSource,
      'apiDataSourceName': instance.apiDataSourceName,
      'parameters': instance.parameters,
      'dialogTitle': instance.dialogTitle,
      'dialogMessage': instance.dialogMessage,
      'url': instance.url,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
