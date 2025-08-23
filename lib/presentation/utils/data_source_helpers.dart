// lib/presentation/applications/utils/data_source_helpers.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DataSourceHelpers {
  static Color getDataSourceColor(String type) {
    switch (type.toLowerCase()) {
      case 'api':
      case 'rest':
        return AppColors.info;
      case 'graphql':
        return Colors.purple;
      case 'firebase':
        return Colors.orange;
      case 'database':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  static IconData getDataSourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'api':
      case 'rest':
        return Icons.api;
      case 'graphql':
        return Icons.account_tree;
      case 'firebase':
        return Icons.local_fire_department;
      case 'database':
        return Icons.storage;
      default:
        return Icons.cloud;
    }
  }

  static String getDataSourceTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'api':
        return 'REST API';
      case 'rest':
        return 'REST API';
      case 'graphql':
        return 'GraphQL';
      case 'firebase':
        return 'Firebase';
      case 'database':
        return 'Database';
      default:
        return type;
    }
  }
}