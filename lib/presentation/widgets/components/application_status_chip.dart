// lib/presentation/applications/widgets/components/application_status_chip.dart
import 'package:flutter/material.dart';
import '../../utils/build_status_utils.dart';

class ApplicationStatusChip extends StatelessWidget {
  final String status;

  const ApplicationStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = BuildStatusUtils.getBuildStatusColor(status);
    final label = BuildStatusUtils.getBuildStatusLabel(status);

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }
}