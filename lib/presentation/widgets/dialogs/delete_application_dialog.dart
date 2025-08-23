// lib/presentation/applications/widgets/dialogs/delete_application_dialog.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/application_provider.dart';
import '../../../../core/constants/app_colors.dart';

void showDeleteApplicationDialog(
  BuildContext context,
  dynamic application,
  ApplicationProvider provider,
) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete Application'),
      content: Text('Are you sure you want to delete "${application.name}"? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            final success = await provider.deleteApplication(application.id.toString());
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Application deleted'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.go('/applications');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}