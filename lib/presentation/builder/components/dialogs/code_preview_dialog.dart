
// lib/presentation/builder/components/dialogs/code_preview_dialog.dart
import 'package:flutter/material.dart';

class CodePreviewDialog extends StatelessWidget {
  const CodePreviewDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Code Preview'),
      content: const Text('Code preview coming soon!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}