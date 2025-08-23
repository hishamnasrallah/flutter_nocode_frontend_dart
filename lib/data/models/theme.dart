// lib/data/models/theme.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'theme.g.dart';

@JsonSerializable()
class AppTheme extends Equatable {
  final int id;
  final String name;
  @JsonKey(name: 'primary_color')
  final String primaryColor;
  @JsonKey(name: 'accent_color')
  final String accentColor;
  @JsonKey(name: 'background_color')
  final String backgroundColor;
  @JsonKey(name: 'text_color')
  final String textColor;
  @JsonKey(name: 'font_family')
  final String fontFamily;
  @JsonKey(name: 'is_dark_mode')
  final bool isDarkMode;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'applications_count')
  final int? applicationsCount;

  const AppTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
    required this.fontFamily,
    required this.isDarkMode,
    required this.createdAt,
    required this.updatedAt,
    this.applicationsCount,
  });

  factory AppTheme.fromJson(Map<String, dynamic> json) => _$AppThemeFromJson(json);
  Map<String, dynamic> toJson() => _$AppThemeToJson(this);

  @override
  List<Object?> get props => [
    id, name, primaryColor, accentColor, backgroundColor,
    textColor, fontFamily, isDarkMode, createdAt, updatedAt, applicationsCount
  ];
}