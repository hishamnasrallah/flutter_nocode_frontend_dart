// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuildHistory _$BuildHistoryFromJson(Map<String, dynamic> json) => BuildHistory(
      id: (json['id'] as num).toInt(),
      application: (json['application'] as num).toInt(),
      buildId: json['buildId'] as String,
      status: json['status'] as String,
      buildStartTime: DateTime.parse(json['buildStartTime'] as String),
      buildEndTime: json['buildEndTime'] == null
          ? null
          : DateTime.parse(json['buildEndTime'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
      durationDisplay: json['durationDisplay'] as String?,
      logOutput: json['logOutput'] as String?,
      errorMessage: json['errorMessage'] as String?,
      apkFile: json['apkFile'] as String?,
      sourceCodeZip: json['sourceCodeZip'] as String?,
      apkSizeMb: (json['apkSizeMb'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BuildHistoryToJson(BuildHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'application': instance.application,
      'buildId': instance.buildId,
      'status': instance.status,
      'buildStartTime': instance.buildStartTime.toIso8601String(),
      'buildEndTime': instance.buildEndTime?.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
      'durationDisplay': instance.durationDisplay,
      'logOutput': instance.logOutput,
      'errorMessage': instance.errorMessage,
      'apkFile': instance.apkFile,
      'sourceCodeZip': instance.sourceCodeZip,
      'apkSizeMb': instance.apkSizeMb,
    };
