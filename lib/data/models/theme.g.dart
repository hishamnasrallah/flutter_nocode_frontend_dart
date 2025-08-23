// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppTheme _$AppThemeFromJson(Map<String, dynamic> json) => AppTheme(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      primaryColor: json['primaryColor'] as String,
      accentColor: json['accentColor'] as String,
      backgroundColor: json['backgroundColor'] as String,
      textColor: json['textColor'] as String,
      fontFamily: json['fontFamily'] as String,
      isDarkMode: json['isDarkMode'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      applicationsCount: (json['applicationsCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AppThemeToJson(AppTheme instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'primaryColor': instance.primaryColor,
      'accentColor': instance.accentColor,
      'backgroundColor': instance.backgroundColor,
      'textColor': instance.textColor,
      'fontFamily': instance.fontFamily,
      'isDarkMode': instance.isDarkMode,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'applicationsCount': instance.applicationsCount,
    };
