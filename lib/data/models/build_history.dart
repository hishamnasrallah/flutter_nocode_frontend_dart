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

  factory BuildHistory.fromJson(Map<String, dynamic> json) => _$BuildHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$BuildHistoryToJson(this);

  @override
  List<Object?> get props => [
    id, application, buildId, status, buildStartTime, buildEndTime,
    durationSeconds, durationDisplay, logOutput, errorMessage,
    apkFile, sourceCodeZip, apkSizeMb
  ];
}