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

  // Handle both 'theme' (as ID) and 'theme_id'
  @JsonKey(name: 'theme')
  final int? themeId;

  @JsonKey(name: 'theme_name')
  final String? themeName;

  // This will be populated separately if needed
  @JsonKey(includeFromJson: false, includeToJson: false)
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
    this.themeName,
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
    // Handle different date formats
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is String) return DateTime.parse(date);
      return DateTime.now();
    }

    return Application(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      packageName: json['package_name'] as String,
      version: json['version'] as String,
      themeId: json['theme'] as int? ?? json['theme_id'] as int?,
      themeName: json['theme_name'] as String?,
      buildStatus: json['build_status'] as String? ?? 'not_built',
      apkFile: json['apk_file'] as String?,
      sourceCodeZip: json['source_code_zip'] as String?,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      screensCount: json['screens_count'] as int?,
      lastBuild: json['last_build'] as Map<String, dynamic>?,
      statistics: json['statistics'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'package_name': packageName,
    'version': version,
    'theme': themeId,
    'theme_id': themeId,
    'build_status': buildStatus,
    'apk_file': apkFile,
    'source_code_zip': sourceCodeZip,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'screens_count': screensCount,
    'last_build': lastBuild,
    'statistics': statistics,
  };

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
    id, name, description, packageName, version, themeId, themeName, theme,
    buildStatus, apkFile, sourceCodeZip, createdAt, updatedAt,
    screensCount, lastBuild, statistics
  ];
}