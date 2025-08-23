// lib/data/models/build_history.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'build_history.g.dart';

@JsonSerializable()
class BuildHistory extends Equatable {
  final int id;
  final int application;
  final String buildId;
  final String status;
  final DateTime buildStartTime;
  final DateTime? buildEndTime;
  final double? durationSeconds;
  final String? durationDisplay;
  final String? logOutput;
  final String? errorMessage;
  final String? apkFile;
  final String? sourceCodeZip;
  final double? apkSizeMb;

  const BuildHistory({
    required this.id,
    required this.application,
    required this.buildId,
    required this.status,
    required this.buildStartTime,
    this.buildEndTime,
    this.durationSeconds,
    this.durationDisplay,
    this.logOutput,
    this.errorMessage,
    this.apkFile,
    this.sourceCodeZip,
    this.apkSizeMb,
  });

  factory BuildHistory.fromJson(Map<String, dynamic> json) {
  // Parse DateTime safely
  DateTime? parseDate(dynamic date) {
    if (date == null) return null;
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return null;
  }

  // Parse numeric values safely (handle both String and num)
  double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  return BuildHistory(
    id: json['id'] as int,
    application: json['application'] as int,
    buildId: json['build_id']?.toString() ?? 'unknown',
    status: json['status']?.toString() ?? 'unknown',
    buildStartTime: parseDate(json['build_start_time']) ?? DateTime.now(),
    buildEndTime: parseDate(json['build_end_time']),
    durationSeconds: parseDouble(json['duration_seconds']),
    durationDisplay: json['duration_display']?.toString(),
    logOutput: json['log_output']?.toString(),
    errorMessage: json['error_message']?.toString(),
    apkFile: json['apk_file']?.toString(),
    sourceCodeZip: json['source_code_zip']?.toString(),
    apkSizeMb: parseDouble(json['apk_size_mb']),  // Now handles String values
  );
}

  @override
  List<Object?> get props => [
    id, application, buildId, status, buildStartTime, buildEndTime,
    durationSeconds, durationDisplay, logOutput, errorMessage,
    apkFile, sourceCodeZip, apkSizeMb
  ];
}