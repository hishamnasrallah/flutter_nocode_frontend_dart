
// lib/presentation/builder/components/dialogs/screen_settings_dialog.dart
import 'package:flutter/material.dart';

class ScreenSettingsDialog extends StatelessWidget {
  const ScreenSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Screen Settings'),
      content: const Text('Screen settings configuration coming soon!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
