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

  factory Screen.fromJson(Map<String, dynamic> json) {
  // Parse DateTime safely
  DateTime parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  // Parse widgets list safely
  List<AppWidget>? parseWidgets(dynamic widgetsData) {
    if (widgetsData == null) return null;
    if (widgetsData is List) {
      return widgetsData.map((w) => AppWidget.fromJson(w)).toList();
    }
    return null;
  }

  // Handle nullable strings with defaults
  final name = json['name']?.toString() ?? 'Unnamed Screen';
  final routeName = json['route_name']?.toString() ?? '/screen';

  return Screen(
    id: json['id'] as int,
    application: json['application'] as int,
    name: name,
    routeName: routeName,
    isHomeScreen: json['is_home_screen'] == true,
    appBarTitle: json['app_bar_title']?.toString(),
    showAppBar: json['show_app_bar'] != false,  // defaults to true
    showBackButton: json['show_back_button'] != false,  // defaults to true
    backgroundColor: json['background_color']?.toString(),
    widgets: parseWidgets(json['widgets']),
    widgetsCount: json['widgets_count'] as int?,
    createdAt: parseDate(json['created_at']),
    updatedAt: parseDate(json['updated_at']),
  );
}

  @override
  List<Object?> get props => [
    id, application, name, routeName, isHomeScreen, appBarTitle,
    showAppBar, showBackButton, backgroundColor, widgets, widgetsCount,
    createdAt, updatedAt
  ];
}