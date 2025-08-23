// lib/presentation/applications/widgets/dialogs/clone_application_dialog.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/application_provider.dart';
import '../../../../core/constants/app_colors.dart';

void showCloneApplicationDialog(
  BuildContext context,
  dynamic application,
  ApplicationProvider provider,
) {
  final nameController = TextEditingController(text: '${application.name} (Copy)');
  final packageController = TextEditingController(text: '${application.packageName}.copy');

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Clone Application'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'New Application Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: packageController,
            decoration: const InputDecoration(
              labelText: 'New Package Name',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            final newApp = await provider.cloneApplication(
              application.id.toString(),
              name: nameController.text,
              packageName: packageController.text,
            );
            if (newApp != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Application cloned successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.go('/applications/${newApp.id}');
            }
          },
          child: const Text('Clone'),
        ),
      ],
    ),
  );
}