
// lib/presentation/builder/components/dialogs/preview_dialog.dart
import 'package:flutter/material.dart';

class PreviewDialog extends StatelessWidget {
  const PreviewDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Preview'),
      content: const Text('Live preview coming soon!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
