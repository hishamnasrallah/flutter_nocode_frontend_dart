// lib/presentation/applications/widgets/dialogs/add_data_source_dialog.dart
import 'package:flutter/material.dart';

void showAddDataSourceDialog(BuildContext context) {
  // TODO: Implement add data source dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Data Source'),
      content: const Text('Data source creation will be implemented'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}