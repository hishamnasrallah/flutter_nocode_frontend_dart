// lib/data/models/screen.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'app_widget.dart';

part 'screen.g.dart';

@JsonSerializable()
class Screen extends Equatable {
  final int id;
  final int application;
  final String name;
  final String routeName;
  final bool isHomeScreen;
  final String? appBarTitle;
  final bool showAppBar;
  final bool showBackButton;
  final String? backgroundColor;
  final List<AppWidget>? widgets;
  final int? widgetsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Screen({
    required this.id,
    required this.application,
    required this.name,
    required this.routeName,
    required this.isHomeScreen,
    this.appBarTitle,
    required this.showAppBar,
    required this.showBackButton,
    this.backgroundColor,
    this.widgets,
    this.widgetsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Screen.fromJson(Map<String, dynamic> json) => _$ScreenFromJson(json);
  Map<String, dynamic> toJson() => _$ScreenToJson(this);

  @override
  List<Object?> get props => [
    id, application, name, routeName, isHomeScreen, appBarTitle,
    showAppBar, showBackButton, backgroundColor, widgets, widgetsCount,
    createdAt, updatedAt
  ];
}