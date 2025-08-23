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
  @JsonKey(name: 'package_name')
  final String packageName;
  final String version;
  @JsonKey(name: 'theme_id')
  final int? themeId;
  final AppTheme? theme;
  @JsonKey(name: 'build_status')
  final String buildStatus;
  @JsonKey(name: 'apk_file')
  final String? apkFile;
  @JsonKey(name: 'source_code_zip')
  final String? sourceCodeZip;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'screens_count')
  final int? screensCount;
  @JsonKey(name: 'last_build')
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

  factory Application.fromJson(Map<String, dynamic> json) {
    // Handle screens_count from statistics if not at root level
    if (json['screens_count'] == null && json['statistics'] != null) {
      json['screens_count'] = json['statistics']['screens_count'];
    }
    return _$ApplicationFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ApplicationToJson(this);

  // Helper getter to get screens count from either location
  int get actualScreensCount {
    if (screensCount != null) return screensCount!;
    if (statistics != null && statistics!['screens_count'] != null) {
      return statistics!['screens_count'] as int;
    }
    return 0;
  }

  @override
  List<Object?> get props => [
    id, name, description, packageName, version, themeId, theme,
    buildStatus, apkFile, sourceCodeZip, createdAt, updatedAt,
    screensCount, lastBuild, statistics
  ];
}