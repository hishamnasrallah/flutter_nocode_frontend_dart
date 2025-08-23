// lib/data/models/theme.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'theme.g.dart';

@JsonSerializable()
class AppTheme extends Equatable {
  final int id;
  final String name;
  final String primaryColor;
  final String accentColor;
  final String backgroundColor;
  final String textColor;
  final String fontFamily;
  final bool isDarkMode;
  final DateTime createdAt;
  final DateTime updatedAt;
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
