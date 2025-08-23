// lib/presentation/applications/utils/build_status_utils.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BuildStatusUtils {
  static Color getBuildStatusColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.success;
      case 'building':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  static String getBuildStatusLabel(String status) {
    switch (status) {
      case 'success':
        return 'Built';
      case 'building':
        return 'Building';
      case 'failed':
        return 'Failed';
      case 'not_built':
        return 'Not Built';
      default:
        return status;
    }
  }

  static IconData getBuildStatusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle_outline;
      case 'building':
        return Icons.sync;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.circle_outlined;
    }
  }
}