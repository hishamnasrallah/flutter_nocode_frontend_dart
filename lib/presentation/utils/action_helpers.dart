// lib/presentation/applications/utils/action_helpers.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ActionHelpers {
  static Color getActionColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'navigate':
        return AppColors.primary;
      case 'api_call':
        return AppColors.info;
      case 'show_dialog':
        return AppColors.warning;
      case 'open_url':
        return Colors.purple;
      case 'refresh_data':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  static IconData getActionIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'navigate':
        return Icons.arrow_forward;
      case 'api_call':
        return Icons.api;
      case 'show_dialog':
        return Icons.message;
      case 'open_url':
        return Icons.open_in_new;
      case 'refresh_data':
        return Icons.refresh;
      default:
        return Icons.flash_on;
    }
  }

  static String getActionTypeLabel(String? type) {
    switch (type?.toLowerCase()) {
      case 'navigate':
        return 'Navigation';
      case 'api_call':
        return 'API Call';
      case 'show_dialog':
        return 'Show Dialog';
      case 'open_url':
        return 'Open URL';
      case 'refresh_data':
        return 'Refresh Data';
      default:
        return type ?? 'Unknown';
    }
  }
}