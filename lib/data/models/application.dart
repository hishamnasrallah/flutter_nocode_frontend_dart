// lib/data/models/application.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'theme.dart';

part 'application.g.dart';

@JsonSerializable()
class Application extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String packageName;
  final String version;
  final int? themeId;
  final AppTheme? theme;
  final String buildStatus;
  final String? apkFile;
  final String? sourceCodeZip;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? screensCount;
  final Map<String, dynamic>? lastBuild;
  final Map<String, dynamic>? statistics;

  const Application({
    required this.id,
    required this.name,
    this.description,
    required this.packageName,
    required this.version,
    this.themeId,
    this.theme,
    required this.buildStatus,
    this.apkFile,
    this.sourceCodeZip,
    required this.createdAt,
    required this.updatedAt,
    this.screensCount,
    this.lastBuild,
    this.statistics,
  });

  factory Application.fromJson(Map<String, dynamic> json) => _$ApplicationFromJson(json);
  Map<String, dynamic> toJson() => _$ApplicationToJson(this);

  @override
  List<Object?> get props => [
    id, name, description, packageName, version, themeId, theme,
    buildStatus, apkFile, sourceCodeZip, createdAt, updatedAt,
    screensCount, lastBuild, statistics
  ];
}
